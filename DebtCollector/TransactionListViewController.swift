import UIKit
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift
import SwiftyUtils
import MGSwipeTableCell
import RxDataSources
import SCLAlertView


class TransactionListViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    var customResults: Results<GroupTransaction>?
    var date: Date?
    var dataSource: RxTableViewSectionedAnimatedDataSource<GroupedTransactionSection>!
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "GroupedTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        var observable: Observable<Results<GroupTransaction>>
        if let date = self.date {
            let start = Calendar.current.startOfDay(for: date)
            var dateComponents = DateComponents()
            dateComponents.day = 1
            dateComponents.second = -1
            let end = Calendar.current.date(byAdding: dateComponents, to: start)
            observable = Observable.collection(from: RealmWrapper.shared.groupTransactions.sorted(byKeyPath: "date", ascending: false)
                .filter("date BETWEEN %@", [start, end])
            )
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            navigationItem.rightBarButtonItems = []
            navigationItem.title = formatter.string(from: date)
        } else if let customResults = self.customResults {
            observable = Observable.collection(from: customResults)
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))]
            navigationItem.leftBarButtonItems = []
        } else {
            observable = Observable.collection(from: RealmWrapper.shared.groupTransactions.sorted(byKeyPath: "date", ascending: false))
        }
        
        dataSource = RxTableViewSectionedAnimatedDataSource<GroupedTransactionSection>(configureCell:  {
            _, tableView, index, groupTransaction in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GroupedTransactionTableViewCell
            let totalAmount = abs(groupTransaction.transactions.map { $0.amount.value ?? 0 }.reduce(0, +))
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = UserSettings.currencySymbol
            cell.amountLabel.text = formatter.string(from: totalAmount as NSNumber)
            
            cell.transactionNameLabel.text = groupTransaction.title
            cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {
                cell in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    RealmWrapper.shared.realm.beginWrite()
                    RealmWrapper.shared.realm.delete(groupTransaction.transactions)
                    RealmWrapper.shared.realm.delete(groupTransaction)
                    try? RealmWrapper.shared.realm.commitWrite()
                })
                return true
            })]
            if #available(iOS 13.0, *) {
                cell.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
            } else {
                cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            }
            if groupTransaction.transactions.first!.amount.value ?? 0 < 0 {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            } else if groupTransaction.transactions.first!.amount.value ?? 0 > 0 {
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
            return cell
        })
        dataSource.titleForHeaderInSection = {
            dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        observable.map { results -> [GroupedTransactionSection] in
            let transactionByDay =  [Date: [GroupTransaction]](grouping: Array(results), by: {
                transaction in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
                return Calendar.current.date(from: components)!
            })
            return transactionByDay.sorted(by: { $0.key > $1.key }).map { GroupedTransactionSection(items: $0.value) }
        }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(GroupTransaction.self).subscribe(onNext: {
            [weak self] groupTransaction in
            self?.performSegue(withIdentifier: "showDetailTransaction", sender: groupTransaction)
        }).disposed(by: disposeBag)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.updateReadOnlyModePrompt()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.updateReadOnlyModePrompt()
        if let image = UserSettings.bgImage {
            let imageView = UIImageView(image: image)
            tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFill
        } else {
            tableView.backgroundView = UIView()
            if #available(iOS 13.0, *) {
                tableView.backgroundView?.backgroundColor = .systemBackground
            } else {
                tableView.backgroundView?.backgroundColor = .white
            }
        }
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailTransactionViewController {
            vc.groupedTransaction = (sender as! GroupTransaction)
        } else if segue.identifier == "showDrafts" {
            let vc = (segue.destination as! UINavigationController).topViewController as! TransactionListViewController
            vc.customResults = RealmWrapper.shared.draftTransactions
            vc.title = "Drafts"
        }
    }
    
    @IBAction func addTransaction() {
        if UserSettings.readOnlyMode {
            let alert = SCLAlertView()
            alert.showWarning("Read Only Mode", subTitle: "You cannot add transactions in read only mode", closeButtonTitle: "OK")
            return
        }
        
        performSegue(withIdentifier: "newTransaction", sender: nil)
    }
    
    @IBAction func showDrafts() {
        performSegue(withIdentifier: "showDrafts", sender: nil)
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = dataSource.sectionModels[section].header
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        return label
    }
}

struct GroupedTransactionSection: AnimatableSectionModelType {
    typealias Identity = String

    typealias Item = GroupTransaction
    var items: [Item]
    var header: String

    var identity: String {
        return header
    }

    init(original: GroupedTransactionSection, items: [Item]) {
        self = original
        self.items = items
    }

    init(items: [Item]) {
        self.items = items
        if let date = items.first?.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            header = formatter.string(from: date)
        } else {
            header = ""
        }
    }
}

extension GroupTransaction : IdentifiableType {
    typealias Identity = Int

    var identity: Int {
        return hash
    }
}
