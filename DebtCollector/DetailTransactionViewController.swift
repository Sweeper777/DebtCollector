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
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.register(UINib(nibName: "DetailTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<DetailTransactionTableViewSection>(configureCell:  {
            ds, tv, ip, item in
            switch item {
            case .transaction(let transaction):
                let cell = tv.dequeueReusableCell(withIdentifier: "transactionCell") as! DetailTransactionTableViewCell
                let formatter1 = NumberFormatter()
                formatter1.numberStyle = .currency
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
            case .button(title: let title):
                let cell = tv.dequeueReusableCell(withIdentifier: "buttonCell")
                cell!.textLabel!.text = title
                return cell!
            }
        })
        
        Observable.collection(from: groupedTransaction.transactions.sorted(byKeyPath: "personName", ascending: true))
            .map { (transactions) -> [DetailTransactionTableViewSection] in
                var sections = [DetailTransactionTableViewSection.buttonSection(rows: [.button(title: "Delete This Transaction")])]
                sections.append(.transactionSection(rows: transactions.toArray().map { .transaction($0) }))
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(DetailTransactionTableViewSection.DetailTransactionTableViewRow.self).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("Yes", action: {
                self.deleteTransaction()
            })
            alert.addButton("No", action: {})
            alert.showWarning("Delete Transaction", subTitle: "Do you really want to delete this transaction?")
            if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
            }.disposed(by: disposeBag)
    }
    
    func deleteTransaction() {
        try! RealmWrapper.shared.realm.write {
            for transaction in self.groupedTransaction.transactions {
                RealmWrapper.shared.realm.delete(transaction)
            }
            RealmWrapper.shared.realm.delete(self.groupedTransaction)
        }
        navigationController?.popViewController(animated: true)
    }
}

enum DetailTransactionTableViewSection : SectionModelType {
    case buttonSection(rows: [DetailTransactionTableViewRow])
    case transactionSection(rows: [DetailTransactionTableViewRow])
    
    var items: [DetailTransactionTableViewSection.DetailTransactionTableViewRow] {
        switch self {
        case .buttonSection(rows: let rows):
            return rows
        case .transactionSection(rows: let rows):
            return rows
        }
    }
    
    init(original: DetailTransactionTableViewSection, items: [DetailTransactionTableViewSection.DetailTransactionTableViewRow]) {
        switch original {
        case .buttonSection(rows: _):
            self = .buttonSection(rows: items)
        case .transactionSection(rows: _):
            self = .transactionSection(rows: items)
        }
    }
    
    typealias Item = DetailTransactionTableViewRow
    
    enum DetailTransactionTableViewRow {
        case button(title: String)
        case transaction(Transaction)
    }
}
