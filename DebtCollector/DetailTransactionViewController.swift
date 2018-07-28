import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RxDataSources
import SCLAlertView

class DetailTransactionViewController : UITableViewController {
    let disposeBag = DisposeBag()
    
    var groupedTransaction: GroupTransaction!
    
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
