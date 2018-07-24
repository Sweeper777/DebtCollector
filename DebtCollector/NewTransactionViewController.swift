import UIKit
import Eureka

class NewTransactionViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
        
        <<< SegmentedRow<String>(tagReturnedOrBorrowed) {
            row in
            row.options = ["Borrowed", "Returned"]
            row.value = "Borrowed"
        }
        .onChange({ (row) in
           if row.value == "Returned" {
                let row: RowOf<String> = self.form.rowBy(tag: tagTitle)!
                row.value = "Returned Money"
            }
        })
            
        <<< TextRow(tagTitle) {
            row in
            row.title = "Title"
            row.cell.textField.placeholder = "Required"
        }
        
        <<< DateRow(tagDate) {
            row in
            row.title = "Date"
            row.value = Date()
            row.maximumDate = Date()
        }
        
        for i in 0..<RealmWrapper.shared.people.count {
            form +++ Section()
            <<< PickerRow<String>(tagPerson + "\(i)") {
                row in
                row.options = [["Not Selected"], RealmWrapper.shared.people.map { $0.name }].flatMap { $0 }
                row.value = "Not Selected"
            }
        }
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Form tags
let tagTitle = "title"
let tagDate = "date"
let tagReturnedOrBorrowed = "returnedOrBorrowed"
let tagPerson = "person"
let tagAmount = "amount"
let tagDetails = "details"
