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
    }
}