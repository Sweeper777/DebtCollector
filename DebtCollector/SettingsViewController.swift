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
        
        form +++ Section("show presets when...")
        <<< CheckRow(tagShowPresetsWhenBorrowing) {
            row in
            row.title = "Borrowing"
            row.value = UserSettings.showPresetsWhenBorrowing
        }
        <<< CheckRow(tagShowPresetsWhenReturning) {
            row in
            row.title = "Returning"
            row.value = UserSettings.showPresetsWhenReturning
        }
    }
    
    @IBAction func done() {
        let values = form.values()
        UserSettings.detailPresets = (values[tagDetailPresets] as? String) ?? ""
        
        self.dismiss(animated: true, completion: nil)
    }
}

let tagDetailPresets = "detailPresets"
let tagShowPresetsWhenBorrowing = "showPresetsWhenBorrowing"
let tagShowPresetsWhenReturning = "showPresetsWhenReturning"
