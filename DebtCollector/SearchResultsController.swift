import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift

class SearchResultsController: UITableViewController {
    var keywordPredicate: NSPredicate!
    var datePredicate: NSPredicate!
    
    let disposeBag = DisposeBag()
    
    var customResults: Results<GroupTransaction>!
    var dataSource: RxTableViewSectionedAnimatedDataSource<GroupedTransactionSection>!
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "GroupedTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        var observable: Observable<Results<GroupTransaction>>
        
        customResults = RealmWrapper.shared.groupTransactions.filter(keywordPredicate).filter(datePredicate)
        
        observable = Observable.collection(from: customResults)
        
        dataSource = RxTableViewSectionedAnimatedDataSource<GroupedTransactionSection>(configureCell:  {
            _, tableView, index, groupTransaction in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GroupedTransactionTableViewCell
            let totalAmount = abs(groupTransaction.transactions.map { $0.amount.value ?? 0 }.reduce(0, +))
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = UserSettings.currencySymbol
            cell.amountLabel.text = formatter.string(from: totalAmount as NSNumber)
            
            cell.transactionNameLabel.text = groupTransaction.title
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailTransactionViewController {
            vc.groupedTransaction = (sender as! GroupTransaction)
        }
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
