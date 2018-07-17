import UIKit
import RxCocoa
import RxSwift

class PersonViewController : UITableViewController {
    override func viewDidLoad() {
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.register(BriefTransactionTableViewCell.self, forCellReuseIdentifier: "transactionCell")
    }
}
