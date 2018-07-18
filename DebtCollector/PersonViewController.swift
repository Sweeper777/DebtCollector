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
    }
}
