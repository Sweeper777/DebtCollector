import UIKit
import RxCocoa
import RxSwift
import RxRealm
import SwiftyUtils

class TransactionListViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "GroupedTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
}
