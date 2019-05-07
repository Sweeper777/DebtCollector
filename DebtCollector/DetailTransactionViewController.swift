import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RxDataSources
import SCLAlertView

class DetailTransactionViewController : UITableViewController {
    let disposeBag = DisposeBag()
    
    var groupedTransaction: GroupTransaction!
    
    override func viewDidLoad() {
        title = groupedTransaction.title
        
        tableView.register(UINib(nibName: "DetailTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        
        loadDetailTransaction(groupedTransaction)
        tableView.rx.modelSelected(DetailTransactionTableViewSection.DetailTransactionTableViewRow.self).subscribe { [weak self] model in
            guard let modelNonNil = model.element else { return }
            guard let `self` = self else { return }
            if case .button(title: let title, color: _) = modelNonNil {
                if title == "Delete This Transaction" {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("Yes", action: {
                        self.deleteTransaction()
                    })
                    alert.addButton("No", action: {})
                    alert.showWarning("Delete Transaction", subTitle: "Do you really want to delete this transaction?")
                } else if title == "Edit This Transaction" {
                    self.performSegue(withIdentifier: "editTransaction", sender: self)
                }
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            } else if case .image = modelNonNil {
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }.disposed(by: disposeBag)
    }
    
    func loadDetailTransaction(_ groupedTransaction: GroupTransaction) {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.groupedTransaction = groupedTransaction
        title = groupedTransaction.title
        let dataSource = RxTableViewSectionedReloadDataSource<DetailTransactionTableViewSection>(configureCell:  {
            ds, tv, ip, item in
            switch item {
            case .transaction(let transaction):
                let cell = tv.dequeueReusableCell(withIdentifier: "transactionCell") as! DetailTransactionTableViewCell
                let formatter1 = NumberFormatter()
                formatter1.numberStyle = .currency
                formatter1.currencySymbol = UserSettings.currencySymbol
                cell.amountLabel.text = formatter1.string(from: abs(transaction.amount) as NSNumber)
                cell.borrowedReturnedLabel.text = transaction.amount < 0 ? "Returned" : "Borrowed"
                cell.transactionLabel.text = transaction.personName
                cell.selectionStyle = .none
                
                if transaction.details.trimmed() != "" {
                    cell.transactionDetailsLabel.text = transaction.details
                } else {
                    cell.transactionDetailsLabel.removeFromSuperview()
                }
                
                return cell
            case .button(title: let title, color: let color):
                let cell = tv.dequeueReusableCell(withIdentifier: "buttonCell")
                cell!.textLabel!.text = title
                cell?.textLabel?.textColor = color
                return cell!
            case .image(let image):
                let cell = tv.dequeueReusableCell(withIdentifier: "imageCell")
                (cell?.viewWithTag(1) as? UIImageView)?.image = image
                return cell!
            case .text(let text):
                let cell = tv.dequeueReusableCell(withIdentifier: "textCell")
                (cell?.viewWithTag(1) as? UITextView)?.text = text
                cell?.selectionStyle = .none
                return cell!
            }
        })
        
        Observable.collection(from: groupedTransaction.transactions.sorted(byKeyPath: "personName", ascending: true))
            .map { (transactions) -> [DetailTransactionTableViewSection] in
                let sections = [
                    DetailTransactionTableViewSection.buttonSection(rows: [.button(title: "Delete This Transaction", color: .red)]),
                    .buttonSection(rows: [.button(title: "Edit This Transaction", color: UIColor(hex: "3b7b3b"))]),
                    .transactionSection(rows: transactions.toArray().map { .transaction($0) })
                ]
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func deleteTransaction() {
        try! RealmWrapper.shared.realm.write {
            self.groupedTransaction.deleteImage()
            for transaction in self.groupedTransaction.transactions {
                RealmWrapper.shared.realm.delete(transaction)
            }
            RealmWrapper.shared.realm.delete(self.groupedTransaction)
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? NewTransactionViewController {
            vc.detailTransactionVC = self
            vc.transactionToEdit = self.groupedTransaction
        }
    }
}

enum DetailTransactionTableViewSection : SectionModelType {
    case buttonSection(rows: [DetailTransactionTableViewRow])
    case transactionSection(rows: [DetailTransactionTableViewRow])
    case infoSection(rows: [DetailTransactionTableViewRow])
    
    var items: [DetailTransactionTableViewSection.DetailTransactionTableViewRow] {
        switch self {
        case .buttonSection(rows: let rows):
            return rows
        case .transactionSection(rows: let rows):
            return rows
        case .infoSection(rows: let rows):
            return rows
        }
    }
    
    init(original: DetailTransactionTableViewSection, items: [DetailTransactionTableViewSection.DetailTransactionTableViewRow]) {
        switch original {
        case .buttonSection(rows: _):
            self = .buttonSection(rows: items)
        case .transactionSection(rows: _):
            self = .transactionSection(rows: items)
        case .infoSection(rows: let items):
            self = .infoSection(rows: items)
        }
    }
    
    typealias Item = DetailTransactionTableViewRow
    
    enum DetailTransactionTableViewRow {
        case button(title: String, color: UIColor)
        case transaction(Transaction)
        case image(UIImage)
        case text(String)
    }
}
