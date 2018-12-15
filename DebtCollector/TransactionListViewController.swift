import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift
import SwiftyUtils
import MGSwipeTableCell

class TransactionListViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    var date: Date?
    
    override func viewDidLoad() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "GroupedTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        var observable: Observable<Results<GroupTransaction>>
        if let date = self.date {
            let start = Calendar.current.startOfDay(for: date)
            let dateComponents = DateComponents()
            dateComponents.date = 1
            dateComponents.second = -1
            let end = Calendar.current.date(byAdding: dateComponents, to: start)
            observable = Observable.collection(from: RealmWrapper.shared.groupTransactions.sorted(byKeyPath: "date", ascending: false)
                .filter("date BETWEEN %@", [start, end])
            )
        } else {
            observable = Observable.collection(from: RealmWrapper.shared.groupTransactions.sorted(byKeyPath: "date", ascending: false))
        }
        observable.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: GroupedTransactionTableViewCell.self)) {
            index, groupTransaction, cell in
            let totalAmount = abs(groupTransaction.transactions.map { $0.amount }.reduce(0, +))
            let formatter1 = NumberFormatter()
            formatter1.numberStyle = .currency
            formatter1.currencySymbol = UserSettings.currencySymbol
            cell.amountLabel.text = formatter1.string(from: totalAmount as NSNumber)
            
            let formatter2 = DateFormatter()
            formatter2.dateStyle = .short
            formatter2.timeStyle = .none
            cell.dateLabel.text = formatter2.string(from: groupTransaction.date)
            cell.transactionNameLabel.text = groupTransaction.title
            cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {
                cell in
                RealmWrapper.shared.realm.beginWrite()
                RealmWrapper.shared.realm.delete(groupTransaction.transactions)
                RealmWrapper.shared.realm.delete(groupTransaction)
                try? RealmWrapper.shared.realm.commitWrite()
                return true
            })]
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            if groupTransaction.transactions.first!.amount < 0 {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            } else if groupTransaction.transactions.first!.amount > 0 {
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(GroupTransaction.self).subscribe(onNext: {
            [weak self] groupTransaction in
            self?.performSegue(withIdentifier: "showDetailTransaction", sender: groupTransaction)
        }).disposed(by: disposeBag)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let image = UserSettings.bgImage {
            let imageView = UIImageView(image: image)
            tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFill
        } else {
            tableView.backgroundView = UIView()
            tableView.backgroundView?.backgroundColor = .white
        }
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailTransactionViewController {
            vc.groupedTransaction = sender as! GroupTransaction
        }
    }
    
    @IBAction func addTransaction() {
        performSegue(withIdentifier: "newTransaction", sender: nil)
    }
}
