import UIKit
import Eureka

class NewTransactionViewController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
