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
        tableView.register(BriefTransactionTableViewCell.self, forCellReuseIdentifier: "transactionCell")
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
    
    }
}
