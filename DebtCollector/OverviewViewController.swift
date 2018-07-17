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
        
        tableView.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        Observable.collection(from: RealmWrapper.shared.transactions)
            .map {
                transactions -> [(key: Person, value: Double)] in
                var peopleDict = RealmWrapper.shared.people.reduce(into: [Person: Double](), { $0[$1] = 0 })
                for transaction in transactions {
                    if peopleDict[transaction.person!] != nil {
                        peopleDict[transaction.person!]! += transaction.amount
                    }
                }
                let mapped = peopleDict.map({ (x) in
                    return x
                })
                return mapped
            }
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: OverviewTableViewCell.self)) {
                index, personAndAmount, cell in
                cell.nameLabel.text = personAndAmount.key.name
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                cell.amountLabel.text = formatter.string(from: personAndAmount.value as NSNumber)
            }.disposed(by: disposeBag)
    }
}

