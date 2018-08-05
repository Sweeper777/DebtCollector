import UIKit
import SearchTextField

class TestingViewController: UIViewController {
    @IBOutlet var searchTextField: SearchTextField!
    
    @IBAction func button1() {
        searchTextField.filterStrings(["1", "2", "3"])
    }
    
    @IBAction func button2() {
        searchTextField.filterStrings(["A", "B", "C"])
    }
    
    override func viewDidLoad() {
        searchTextField.forceNoFiltering = true
        searchTextField.startVisible = true
        searchTextField.theme.bgColor = .white
        searchTextField.filterStrings(["1", "2", "3"])
    }
}
