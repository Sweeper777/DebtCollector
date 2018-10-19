import UIKit
import Eureka
import LTHPasscodeViewController

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
        
        +++ TextRow(tagCurrencySymbol) {
            row in
            row.title = "Currenct Symbol"
            row.cell.textField.placeholder = "Default"
            row.value = UserSettings.currencySymbol
        }
        let passcodeSection = Section("passcode")
        if LTHPasscodeViewController.doesPasscodeExist() {
            passcodeSection <<< ButtonRow() {
                row in
                row.title = "Change Passcode"
                row.cell.tintColor = UIColor(hex: "3b7b3b")
            }
            .onCellSelection({ [weak self] (cell, row) in
                self?.saveSettings()
                self?.performSegue(withIdentifier: "unwindForChangePasscode", sender: nil)
            })
            <<< ButtonRow() {
                row in
                row.title = "Remove Passcode"
                row.cell.tintColor = .red
            }
            .onCellSelection({ [weak self] (cell, row) in
                self?.saveSettings()
                self?.performSegue(withIdentifier: "unwindForRemovePasscode", sender: nil)
            })
        } else {
            passcodeSection <<< ButtonRow() {
                row in
                row.title = "Set Passcode"
                row.cell.tintColor = UIColor(hex: "3b7b3b")
            }
            .onCellSelection({ [weak self] (cell, row) in
                self?.saveSettings()
                self?.performSegue(withIdentifier: "unwindForSetPasscode", sender: nil)
            })
        }
        form +++ passcodeSection
    }
    
    private func saveSettings() {
        let values = form.values()
        UserSettings.detailPresets = (values[tagDetailPresets] as? String) ?? ""
        UserSettings.showDetailPresetsOnBorrow = (values[tagShowDetailPresetsOnBorrow] as? Bool) ?? false
        UserSettings.showDetailPresetsOnReturn = (values[tagShowDetailPresetsOnReturn] as? Bool) ?? false
    }
    
    @IBAction func done() {
        saveSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
}

let tagDetailPresets = "tagDetailPresets"
let tagShowDetailPresetsOnBorrow = "showDetailPresetsOnBorrow"
let tagShowDetailPresetsOnReturn = "showDetailPresetsOnReturn"
let tagCurrencySymbol = "currencySymbol"
