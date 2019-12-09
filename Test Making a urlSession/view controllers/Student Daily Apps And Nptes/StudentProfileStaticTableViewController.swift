//
//  StudentProfileStaticTableViewController.swift
//


import UIKit

class StudentProfileStaticTableViewController: UITableViewController {

    
    @IBOutlet var profileForDayLabel: [UILabel]!
    @IBOutlet weak var notesLabel: UITextView!
    

    var user : User!
    var student : Student!
    var daySelected = 99
    var notesDelegate: NotesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        student = Student.getStudentFromUser(user)
        dump(student)
        
//        navigationItem.title = "This is the title"
        
        navigationItem.prompt = "Setup the Student"
        
        /// Set navigation left bar button
        ///
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    
        notesLabel.delegate = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        profileForDayLabel[0].text = student.mondayName.replacingOccurrences(of: UserDefaultsHelper.appFilter, with: "")
        profileForDayLabel[1].text = student.tuesdayName.replacingOccurrences(of: UserDefaultsHelper.appFilter, with: "")
        profileForDayLabel[2].text = student.wednesdayName.replacingOccurrences(of: UserDefaultsHelper.appFilter, with: "")
        profileForDayLabel[3].text = student.thursdayName.replacingOccurrences(of: UserDefaultsHelper.appFilter, with: "")
        profileForDayLabel[4].text = student.fridayName.replacingOccurrences(of: UserDefaultsHelper.appFilter, with: "")
        notesLabel.text = student.notes
    }
 
}

extension StudentProfileStaticTableViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        print("we ended editing")
        
        /// Check if the note changed
        if notesLabel.text != student.notes {
            student.notes = notesLabel.text
            print(" Notes have changed")
            upDateStudentAppNotes()
        }
    /* Updated for Swift 4 */

        
//        store.student.notes = textView.text
//        Student.saveTheStudent(self.store.student)
    }
    
     /* Updated for Swift 4 */
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if(text == "\n") {
             textView.resignFirstResponder()
             return false
         }
         return true
     }
}

extension StudentProfileStaticTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let appProfileVC = segue.destination as? AppProfilesTableViewController else {
            fatalError("could not cast the destination app segue")
        }
        
        switch segue.identifier {
        case "monday":
            daySelected = 0
            appProfileVC.navigationItem.prompt = "Monday apps for \(student.firstName)"
        case "tuesday":
            daySelected = 1
            appProfileVC.navigationItem.prompt = "Tuesday apps for \(student.firstName)"
        case "wednesday":
            daySelected = 2
            appProfileVC.navigationItem.prompt = "Wednesday apps for \(student.firstName)"
        case "thursday":
            daySelected = 3
            appProfileVC.navigationItem.prompt = "Thursday apps for \(student.firstName)"
        case "friday":
            daySelected = 4
            appProfileVC.navigationItem.prompt = "Friday apps for \(student.firstName)"
        default:
            break
        }
    }
    
    @IBAction func backToStudentAppProfile(seque: UIStoryboardSegue)  {
        print("in unwind segue")
        guard let appProfilesTableVC =  seque.source as? AppProfilesTableViewController  else {fatalError("Was not the AppProfilesTable VC")}
        print(appProfilesTableVC.profiles[appProfilesTableVC.rowSelected])

        // profileForDayLabel[daySelected].text = appProfilesTableVC.profiles[appProfilesTableVC.rowSelected].name
        profileForDayLabel[daySelected].text = appProfilesTableVC.profileArray[appProfilesTableVC.navBarSegmentedControl.selectedSegmentIndex][appProfilesTableVC.rowSelected].name.replacingOccurrences(of: "Profile-App-", with: "")
        daySelected = 99
        
        upDateStudentAppNotes()
    }
    
    func upDateStudentAppNotes()  {
        // Build the app profile portion of the note
        let profileNoteDelimiter = "~#~"
        guard let profileForDayLabel = profileForDayLabel else {fatalError("eeeee")}
        print(profileForDayLabel.count)
        let profileArrayNoNulls = profileForDayLabel.compactMap { $0.text }
        print(profileArrayNoNulls)
        
        var studentProfileListTemp = profileNoteDelimiter
        for item in profileArrayNoNulls {
            studentProfileListTemp.append((item.isEmpty ? "" : UserDefaultsHelper.appFilter) + item + ";")
        }
        var studentProfileList = String(studentProfileListTemp.dropLast())
        studentProfileList.append(profileNoteDelimiter)
        
        
//        var studentProfileList = profileArrayNoNulls.reduce(profileNoteDelimiter) { (x, y)  in
//            x + (x == profileNoteDelimiter ? "" : ";") +  y
//        }
        
        let trimmedNote = student.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullNote = trimmedNote +  "   " + studentProfileList
        print(fullNote)
        
        dump(student)
        print(String(user.id))
        
        GetDataApi.updateUserProperty(GeneratedReq.init(request: ValidReqs.updateUserProperty(userId: String(student.id), propertyName: "notes", propertyValue: fullNote))) {
            DispatchQueue.main.async {
                self.notesDelegate?.updateStudentNote(passedNoted: fullNote)
                // self.presentAlertWithTitle("Update Done", message: "Update successful, student profile set")
                print("````````````Hooray Job well done")
            }
        }
    }
}
