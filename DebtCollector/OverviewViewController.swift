import UIKit
import RxSwift
import RxCocoa
import RxRealm
import LTHPasscodeViewController

class OverviewViewController: UITableViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        Observable.combineLatest(Observable.collection(from: RealmWrapper.shared.transactions), Observable.collection(from: RealmWrapper.shared.people), resultSelector: { (transactions: $0, people: $1) })
            .map {
                transactions, people -> [(key: String, value: Double)] in
                var peopleDict = RealmWrapper.shared.people.reduce(into: [String: Double](), { $0[$1.name] = 0 })
                for transaction in transactions {
                    if peopleDict[transaction.personName] != nil {
                        peopleDict[transaction.personName]! += transaction.amount.value ?? 0
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
                formatter.currencySymbol = UserSettings.currencySymbol
                cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                cell.amountLabel.text = formatter.string(from: personAndAmount.value as NSNumber)
            }.disposed(by: disposeBag)
        
        LTHPasscodeViewController.sharedUser().navigationBarTintColor = UIColor(hex: "4f42fd")
        LTHPasscodeViewController.sharedUser().navigationTitleColor = UIColor.white
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().navigationTintColor = UIColor.white
        
        if LTHPasscodeViewController.doesPasscodeExist() {
            //if LTHPasscodeViewController.didPasscodeTimerEnd() {
            LTHPasscodeViewController.sharedUser().showLockScreen(withAnimation: true, withLogout: true, andLogoutTitle: nil)
            //}
        }
        
        let o1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        let o2 = o1.map { $0 * 10 }
        Observable.combineLatest(o1, o2).subscribe(onNext: { print($0) }).disposed(by: disposeBag)
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
    
    @IBAction func unwindForChangePasscode(segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            [weak self] in
            self.map { LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: $0, asModal: true) }
        }
    }
    
    @IBAction func unwindForSetPasscode(segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            [weak self] in
            self.map { LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: $0, asModal: true) }
        }
        
    }
    
    @IBAction func unwindForRemovePasscode(segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            [weak self] in
            self.map { LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: $0, asModal: true) }
        }
    }
}

