import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RxDataSources

class PersonViewController : UITableViewController {
    let disposeBag = DisposeBag()
    
    var person: Person!
    
    override func viewDidLoad() {
        title = person.name
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.register(UINib(nibName: "BriefTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<PersonTableViewSection>(configureCell:  {
            ds, tv, ip, item in
            switch item {
            case .transaction(let transaction):
                let cell = tv.dequeueReusableCell(withIdentifier: "transactionCell") as! BriefTransactionTableViewCell
                cell.amountLabel.text = "\(abs(transaction.amount))"
                cell.borrowedReturnedLabel.text = transaction.amount < 0 ? "Returned" : "Borrowed"
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                cell.dateLabel.text = formatter.string(from: transaction.date)
                cell.transactionLabel.text = transaction.parentTransactions.first!.title
                cell.selectionStyle = .none
                return cell
            case .button(title: let title):
                let cell = tv.dequeueReusableCell(withIdentifier: "buttonCell")
                cell!.textLabel!.text = title
                return cell!
            }
        })
    }
}

enum PersonTableViewSection : SectionModelType {
    case buttonSection(rows: [PersonTableViewRow])
    case transactionSection(rows: [PersonTableViewRow])
    
    var items: [PersonTableViewSection.PersonTableViewRow] {
        switch self {
        case .buttonSection(rows: let rows):
            return rows
        case .transactionSection(rows: let rows):
            return rows
        }
    }
    
    init(original: PersonTableViewSection, items: [PersonTableViewSection.PersonTableViewRow]) {
        switch original {
        case .buttonSection(rows: _):
            self = .buttonSection(rows: items)
        case .transactionSection(rows: _):
            self = .transactionSection(rows: items)
        }
    }
    
    typealias Item = PersonTableViewRow
    
    enum PersonTableViewRow {
        case button(title: String)
        case transaction(Transaction)
    }
}
