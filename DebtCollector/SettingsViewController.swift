import UIKit
import Eureka

class SettingsViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "transaction detail presets", footer: "These are preset options that will show up when you start typing in the \"Details\" field. Write one on each line.")
        <<< TextAreaRow(tagDetailPresets) {
            row in
            row.value = UserSettings.detailPresets
        }
        
        form +++ Section("show detail presets when")
        <<< SwitchRow(tagShowDetailPresetsOnBorrow) {
            row in
            row.title = "Borrowing"
            row.value = UserSettings.showDetailPresetsOnBorrow
        }
        <<< SwitchRow(tagShowDetailPresetsOnReturn) {
            row in
            row.title = "Returning"
            row.value = UserSettings.showDetailPresetsOnReturn
        }
    }
    
    @IBAction func done() {
        let values = form.values()
        UserSettings.detailPresets = (values[tagDetailPresets] as? String) ?? ""
        UserSettings.showDetailPresetsOnBorrow = (values[tagShowDetailPresetsOnBorrow] as? Bool) ?? false
        UserSettings.showDetailPresetsOnReturn = (values[tagShowDetailPresetsOnReturn] as? Bool) ?? false
        
        self.dismiss(animated: true, completion: nil)
    }
}

let tagDetailPresets = "tagDetailPresets"
let tagShowDetailPresetsOnBorrow = "showDetailPresetsOnBorrow"
let tagShowDetailPresetsOnReturn = "showDetailPresetsOnReturn"
