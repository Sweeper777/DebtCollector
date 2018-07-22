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
