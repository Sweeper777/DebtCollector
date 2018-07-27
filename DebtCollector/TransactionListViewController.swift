import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift
import SwiftyUtils

class TransactionListViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "GroupedTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        Observable.collection(from: RealmWrapper.shared.groupTransactions.sorted(byKeyPath: "date"))
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: GroupedTransactionTableViewCell.self)) {
                index, groupTransaction, cell in
                let totalAmount = abs(groupTransaction.transactions.map { $0.amount }.reduce(0, +))
                let formatter1 = NumberFormatter()
                formatter1.numberStyle = .currency
                cell.amountLabel.text = formatter1.string(from: totalAmount as NSNumber)
                
                let formatter2 = DateFormatter()
                formatter2.dateStyle = .short
                formatter2.timeStyle = .none
                cell.dateLabel.text = formatter2.string(from: groupTransaction.date)
                cell.transactionNameLabel.text = groupTransaction.title
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func addTransaction() {
        performSegue(withIdentifier: "newTransaction", sender: nil)
    }
}
