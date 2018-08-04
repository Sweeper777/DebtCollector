import UIKit
import Eureka

class SettingsViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "detail presets (borrowing)", footer: "These are preset options that will show up when you start typing in the \"Details\" field when adding a borrowing transaction. Write one on each line.")
        <<< TextAreaRow(tagDetailPresetsBorrowing) {
            row in
            row.value = UserSettings.detailPresetsForBorrowing
        }
    }
    
    @IBAction func done() {
        let values = form.values()
        UserSettings.detailPresets = (values[tagDetailPresets] as? String) ?? ""
        
        self.dismiss(animated: true, completion: nil)
    }
}

let tagDetailPresets = "detailPresets"
