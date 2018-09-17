import UIKit
import Eureka
import SCLAlertView
import RealmSwift
import SearchTextField

class NewTransactionViewController : FormViewController {
    
    var personNameAlreadyFilledIn: String?
    var transactionToEdit: GroupTransaction?
    
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
            row.value = transactionToEdit?.date ?? Date()
            row.maximumDate = Date()
        }
        
        let loopCount = personNameAlreadyFilledIn == nil ? RealmWrapper.shared.people.count : 1
        
        for i in 0..<loopCount {
            form +++ Section()
            <<< PickerInlineRow<String>(tagPerson + "\(i)") {
                row in
                row.title = "Person"
                row.options = [["<Not Selected>"], RealmWrapper.shared.people.map { $0.name }.sorted()].flatMap { $0 }
                row.value = "<Not Selected>"
                
                if i == 0 && personNameAlreadyFilledIn != nil {
                    row.disabled = true
                    row.evaluateDisabled()
                    row.value = personNameAlreadyFilledIn
                }
            }
            <<< DecimalRow(tagAmount + "\(i)") {
                row in
                row.title = "Amount (\(Locale.current.currencySymbol ?? Locale.current.currencyCode ?? "$"))"
                row.cell.textField.placeholder = "0.00"
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .currency
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
                tf.forceNoFiltering = true
                tf.startVisible = true
                tf.theme.bgColor = .white
                tf.addTarget(self, action: #selector(didEndEditing), for: UIControlEvents.editingDidEnd)
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
        for i in 0..<RealmWrapper.shared.people.count  {
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
            if amount <= 0 {
                showErrorMessage("Amount cannot be less than or equal to 0!")
                return
            }
            let transaction = Transaction()
            transaction.personName = name
            transaction.details = values[tagDetails + "\(i)"] as? String ?? ""
            transaction.date = values[tagDate] as? Date ?? Date()
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
        groupedTransaction.date = values[tagDate] as? Date ?? Date()
        transactions.forEach {
            groupedTransaction.transactions.append($0)
        }
        
        try! RealmWrapper.shared.realm.write {
            transactions.forEach {
                RealmWrapper.shared.realm.add($0)
            }
            RealmWrapper.shared.realm.add(groupedTransaction)
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
}

// MARK: Form tags
let tagTitle = "title"
let tagDate = "date"
let tagReturnedOrBorrowed = "returnedOrBorrowed"
let tagPerson = "person"
let tagAmount = "amount"
let tagDetails = "details"
