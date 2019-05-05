import UIKit
import Eureka
import SCLAlertView
import RealmSwift
import SearchTextField

class NewTransactionViewController : FormViewController {
    
    var personNameAlreadyFilledIn: String?
    var transactionToEdit: GroupTransaction?
    var detailTransactionVC: DetailTransactionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
            
            <<< SegmentedRow<String>(tagReturnedOrBorrowed) {
                row in
                row.options = ["Borrowed", "Returned"]
                row.value = "Borrowed"
                if let transaction = self.transactionToEdit {
                    row.value = transaction.transactions.first!.amount < 0 ? "Returned" : "Borrowed"
                }
                }
                .onChange({ [weak self] (row) in
                    if row.value == "Returned" {
                        let row: RowOf<String>? = self?.form.rowBy(tag: tagTitle)
                        row?.value = "\((self?.personNameAlreadyFilledIn ?? "") + " ")Returned Money"
                        row?.updateCell()
                    } else if let personName = self?.personNameAlreadyFilledIn {
                        let row: RowOf<String>? = self?.form.rowBy(tag: tagTitle)
                        row?.value = "\(personName) Borrowed Money"
                        row?.updateCell()
                    } else {
                        let row: RowOf<String>? = self?.form.rowBy(tag: tagTitle)
                        row?.value = ""
                        row?.updateCell()
                    }
                    self?.form.allRows.filter { ($0.tag!.hasPrefix("details")) }.forEach { $0.updateCell() }
                })
            
            <<< TextRow(tagTitle) {
                [weak self] row in
                row.title = "Title"
                if let personName = self?.personNameAlreadyFilledIn {
                    row.value = "\(personName) Borrowed Money"
                }
                if let transaction = transactionToEdit {
                    row.value = transaction.title
                }
                row.cell.textField.placeholder = "Required"
            }
            
            <<< DateRow(tagDate) {
                row in
                row.title = "Date"
                row.value = transactionToEdit?.date ?? today()
                row.maximumDate = today()
        }
        
        let loopCount = transactionToEdit?.transactions.count ?? (personNameAlreadyFilledIn == nil ? RealmWrapper.shared.people.count : 1)
        let personNameOptions = Array(Set(transactionToEdit?.transactions.map { $0.personName } ?? [])
            .union(RealmWrapper.shared.people.map { $0.name })).sorted()
        
        for i in 0..<loopCount {
            form +++ Section()
                <<< PickerInlineRow<String>(tagPerson + "\(i)") {
                    row in
                    row.title = "Person"
                    row.options = [["<Not Selected>"], personNameOptions].flatMap { $0 }
                    row.value = transactionToEdit?.transactions[i].personName ?? "<Not Selected>"
                    
                    if i == 0 && personNameAlreadyFilledIn != nil {
                        row.disabled = true
                        row.evaluateDisabled()
                        row.value = personNameAlreadyFilledIn
                    }
                }
                <<< DecimalRow(tagAmount + "\(i)") {
                    row in
                    row.title = "Amount (\(UserSettings.currencySymbol ?? Locale.current.currencySymbol ?? "$"))"
                    row.cell.textField.placeholder = "0.00"
                    
                    row.value = (transactionToEdit?.transactions[i].amount).map(abs)
                }
                
                <<< SearchTextRow(tagDetails + "\(i)") {
                    [weak self]
                    row in
                    
                    guard let `self` = self else { return }
                    
                    row.cell.textField.placeholder = "Details (Optional)"
                    
                    row.value = transactionToEdit?.transactions[i].details
                    
                    guard let tf = row.cell.textField as? SearchTextField else {
                        return
                    }
                    
                    tf.itemSelectionHandler = {
                        items, itemIndex in
                        row.cell.textField.text = items[itemIndex].title
                        row.value = items[itemIndex].title
                    }
                    
                    tf.startVisible = true
                    tf.theme.bgColor = .white
                    tf.theme.font = UIFont.systemFont(ofSize: 22)
                    tf.addTarget(self, action: #selector(didEndEditing), for: UIControl.Event.editingDidEnd)
                    }
                    .cellUpdate({
                        [weak self] (cell, row) in
                        guard let `self` = self else { return }
                        guard let tf = cell.textField as? SearchTextField else {
                            return
                        }
                        let mode = self.form.values()[tagReturnedOrBorrowed] as? String ?? "Borrowed"
                        let shouldShowPresets = (mode == "Borrowed" && UserSettings.showDetailPresetsOnBorrow) ||
                            (mode == "Returned" && UserSettings.showDetailPresetsOnReturn)
                        let filterStrings = shouldShowPresets ?
                            UserSettings.detailPresets.split(separator: "\n").map(String.init) :
                            []
                        if (tf.filterDataSource.map { $0.title }) != filterStrings {
                            tf.filterStrings(filterStrings)
                        }
                    })
        }
        
        // MARK: new empty rows
        
        for i in loopCount..<personNameOptions.count {
            form +++ Section()
                <<< PickerInlineRow<String>(tagPerson + "\(i)") {
                    row in
                    row.title = "Person"
                    row.options = [["<Not Selected>"], personNameOptions].flatMap { $0 }
                    row.value = "<Not Selected>"
                }
                <<< DecimalRow(tagAmount + "\(i)") {
                    row in
                    row.title = "Amount (\(UserSettings.currencySymbol ?? Locale.current.currencySymbol ?? "$"))"
                    row.cell.textField.placeholder = "0.00"
                }
                
                <<< SearchTextRow(tagDetails + "\(i)") {
                    [weak self]
                    row in
                    
                    guard let `self` = self else { return }
                    
                    row.cell.textField.placeholder = "Details (Optional)"
                    
                    guard let tf = row.cell.textField as? SearchTextField else {
                        return
                    }
                    
                    tf.itemSelectionHandler = {
                        items, itemIndex in
                        row.cell.textField.text = items[itemIndex].title
                        row.value = items[itemIndex].title
                    }
                    
                    tf.startVisible = true
                    tf.theme.bgColor = .white
                    tf.theme.font = UIFont.systemFont(ofSize: 22)
                    tf.addTarget(self, action: #selector(didEndEditing), for: UIControl.Event.editingDidEnd)
                    }
                    .cellUpdate({
                        [weak self] (cell, row) in
                        guard let `self` = self else { return }
                        guard let tf = cell.textField as? SearchTextField else {
                            return
                        }
                        let mode = self.form.values()[tagReturnedOrBorrowed] as? String ?? "Borrowed"
                        let shouldShowPresets = (mode == "Borrowed" && UserSettings.showDetailPresetsOnBorrow) ||
                            (mode == "Returned" && UserSettings.showDetailPresetsOnReturn)
                        let filterStrings = shouldShowPresets ?
                            UserSettings.detailPresets.split(separator: "\n").map(String.init) :
                            []
                        if (tf.filterDataSource.map { $0.title }) != filterStrings {
                            tf.filterStrings(filterStrings)
                        }
                    })
        }
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        if transactionToEdit == nil {
            let values = form.values()
            let date = values[tagDate] as? Date ?? today()
            let type = values[tagReturnedOrBorrowed] as? String ?? ""
            if type == "Returned" && sameDayReturnExists(date: date) {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("Yes", action: saveTransaction)
                alert.addButton("No", action: {})
                alert.showWarning("Warning!", subTitle: "There is a return transaction on the same day. Do you still want to create a new return transaction?")
            } else {
                saveTransaction()
            }
        } else {
            saveTransaction()
        }
    }
    
    func sameDayReturnExists(date: Date) -> Bool {
        let queryResult = RealmWrapper.shared.groupTransactions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.transactions.first!.amount < 0 }
        return queryResult.count > 0
    }
    
    func saveTransaction() {
        let values = form.values()
        guard let title = values[tagTitle] as? String else {
            showErrorMessage("Please enter a title!")
            return
        }
        if title.trimmed() == "" {
            showErrorMessage("Please enter a title!")
            return
        }
        var transactions = [Transaction]()
        let personNameOptions = Array(Set(transactionToEdit?.transactions.map { $0.personName } ?? [])
            .union(RealmWrapper.shared.people.map { $0.name })).sorted()
        for i in 0..<personNameOptions.count  {
            guard let name = values[tagPerson + "\(i)"] as? String else {
                continue
            }
            if name == "<Not Selected>" {
                continue
            }
            if transactions.contains(where: { $0.personName == name }) {
                showErrorMessage("There are duplicate names in the transaction!")
                return
            }
            guard let amount = values[tagAmount + "\(i)"] as? Double else {
                showErrorMessage("Please enter an amount for \(name)!")
                return
            }
            if amount < 0 {
                showErrorMessage("Amount cannot be less than to 0!")
                return
            }
            let transaction = Transaction()
            transaction.personName = name
            transaction.details = values[tagDetails + "\(i)"] as? String ?? ""
            transaction.date = values[tagDate] as? Date ?? today()
            if values[tagReturnedOrBorrowed] as? String == "Returned" {
                transaction.amount = -amount
            } else {
                transaction.amount = amount
            }
            transactions.append(transaction)
        }
        
        if transactions.isEmpty {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let groupedTransaction = GroupTransaction()
        groupedTransaction.title = title
        groupedTransaction.date = values[tagDate] as? Date ?? today()
        transactions.forEach {
            groupedTransaction.transactions.append($0)
        }
        
        try! RealmWrapper.shared.realm.write {
            transactions.forEach {
                RealmWrapper.shared.realm.add($0)
            }
            RealmWrapper.shared.realm.add(groupedTransaction)
        }
        
        if let oldTransaction = transactionToEdit, let vc = detailTransactionVC {
            vc.loadDetailTransaction(groupedTransaction)
            
            if oldTransaction.imageName != "" && imageChanged {
               oldTransaction.deleteImage()
            }
            
            try! RealmWrapper.shared.realm.write {
                for subtransaction in oldTransaction.transactions {
                    RealmWrapper.shared.realm.delete(subtransaction)
                }
                RealmWrapper.shared.realm.delete(oldTransaction)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorMessage(_ msg: String) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: msg)
    }
    
    @objc func didEndEditing(_ sender: SearchTextField) {
        sender.hideResultsList()
    }
    
    private func today() -> Date {
        let date = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components)!
    }
}

// MARK: Form tags
let tagTitle = "title"
let tagDate = "date"
let tagReturnedOrBorrowed = "returnedOrBorrowed"
let tagPerson = "person"
let tagAmount = "amount"
let tagDetails = "details"
