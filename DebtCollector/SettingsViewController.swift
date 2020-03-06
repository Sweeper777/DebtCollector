import UIKit
import Eureka
import ImageRow
import LocalAuthentication
import SCLAlertView

class SettingsViewController : FormViewController {
    
    var bgImageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "transaction detail presets", footer: "These are preset options that will show up when you start typing in the \"Details\" field. Write one on each line.")
        <<< TextAreaRow(tagDetailPresets) {
            row in
            row.value = UserSettings.detailPresets
        }
        
        form +++ Section(header: "transaction title presets", footer: "These are preset options that will show up when you start typing in the \"Title\" field. Write one on each line.")
            <<< TextAreaRow(tagTitlePresets) {
                row in
                row.value = UserSettings.titlePresets
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
            row.title = "Currency Symbol"
            row.cell.textField.placeholder = "Default"
            row.value = UserSettings.currencySymbol
        }
        
        +++ ImageRow(tagBgImage) {
            row in
            row.value = UserSettings.bgImage
            row.title = "Background"
        }.onChange({ [weak self] (row) in
            self?.bgImageChanged = true
        })
        
        +++ ButtonRow() {
            row in
            row.title = "People"
        }
        .onCellSelection({ [weak self] (cell, row) in
            self?.performSegue(withIdentifier: "showPeople", sender: nil)
        })
        
        +++ ButtonRow() {
            row in
            row.title = "Export Data"
        }
        .onCellSelection({ (cell, row) in
            guard let realmURL = RealmWrapper.shared.realm.configuration.fileURL else {
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "Unable to export!", closeButtonTitle: "OK")
                return
            }
            let vc = UIActivityViewController(activityItems: [realmURL], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        })
        
        let passcodeSection = Section(header: "passcode", footer: "The iPhone passcode will be used.")
        passcodeSection <<< SwitchRow(tagUsePasscode) {
            row in
            row.title = "Use Passcode"
            row.value = UserSettings.passcodeEnabled
        }
        
        form +++ passcodeSection
        
        form +++ SwitchRow(tagReadOnlyMode) {
            row in
            row.title = "Read Only Mode"
            row.value = UserSettings.readOnlyMode
        }
        .onChange({ (row) in
            if let newReadOnlyMode = row.value {
                if UserSettings.readOnlyMode && !newReadOnlyMode {
                    self.authenticateDisableReadOnlyMode { (success) in
                        if success {
                            UserSettings.readOnlyMode = newReadOnlyMode
                        } else {
                            row.value = UserSettings.readOnlyMode
                        }
                    }
                } else {
                    UserSettings.readOnlyMode = newReadOnlyMode
                }
            }
        })
    }
    
    private func saveSettings() {
        let values = form.values()
        UserSettings.detailPresets = (values[tagDetailPresets] as? String) ?? ""
        UserSettings.titlePresets = (values[tagTitlePresets] as? String) ?? ""
        UserSettings.showDetailPresetsOnBorrow = (values[tagShowDetailPresetsOnBorrow] as? Bool) ?? false
        UserSettings.showDetailPresetsOnReturn = (values[tagShowDetailPresetsOnReturn] as? Bool) ?? false
        UserSettings.currencySymbol = values[tagCurrencySymbol] as? String
        UserSettings.passcodeEnabled = values[tagUsePasscode] as? Bool ?? false
        if bgImageChanged {
            UserSettings.bgImage = values[tagBgImage] as? UIImage
        }
    }
    
    private func authenticateDisableReadOnlyMode(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To disable read only mode", reply: { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            })
        } else {
            completion(true)
        }
    }
    
    @IBAction func done() {
        if UserSettings.readOnlyMode {
            let alert = SCLAlertView()
            alert.showWarning("Read Only Mode", subTitle: "Settings are not saved")
        }
        
        saveSettings()
        
        performSegue(withIdentifier: "unwindToOverview", sender: nil)
    }
}

let tagDetailPresets = "tagDetailPresets"
let tagShowDetailPresetsOnBorrow = "showDetailPresetsOnBorrow"
let tagShowDetailPresetsOnReturn = "showDetailPresetsOnReturn"
let tagCurrencySymbol = "currencySymbol"
let tagBgImage = "bgImage"

let tagTitlePresets = "titlePresets"
let tagReadOnlyMode = "readOnlyMode"
let tagUsePasscode = "usePasscode"
