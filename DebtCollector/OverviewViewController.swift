import UIKit
import RxSwift
import RxCocoa
import RxRealm

class OverviewViewController: UITableViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        Observable.collection(from: RealmWrapper.shared.transactions)
            .map {
                transactions -> [(key: String, value: Double)] in
                var peopleDict = RealmWrapper.shared.people.reduce(into: [String: Double](), { $0[$1.name] = 0 })
                for transaction in transactions {
                    if peopleDict[transaction.personName] != nil {
                        peopleDict[transaction.personName]! += transaction.amount
                    }
                }
                let mapped = peopleDict.map({ (x) in
                    return x
                })
                return mapped.sorted(by: { ($0.value, $1.key) > ($1.value, $0.key) })
            }
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: OverviewTableViewCell.self)) {
                index, personAndAmount, cell in
                cell.nameLabel.text = personAndAmount.key
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                cell.amountLabel.text = formatter.string(from: personAndAmount.value as NSNumber)
            }.disposed(by: disposeBag)
    }
}

