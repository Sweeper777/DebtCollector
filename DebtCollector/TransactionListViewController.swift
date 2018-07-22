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
        
        Observable.collection(from: RealmWrapper.shared.groupTransactions)
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: GroupedTransactionTableViewCell.self)) {
                index, groupTransaction, cell in
            }
            .disposed(by: disposeBag)
    }
}
