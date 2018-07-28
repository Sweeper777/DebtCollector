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
