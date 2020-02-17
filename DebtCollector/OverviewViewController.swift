import UIKit
import RxSwift
import RxCocoa
import RxRealm

extension UINavigationController {
    func updateReadOnlyModePrompt() {
        if UserSettings.readOnlyMode {
            topViewController?.navigationItem.prompt = "Read Only Mode"
        } else {
            topViewController?.navigationItem.prompt = nil
        }
        navigationBar.setNeedsLayout()
    }
}

class OverviewViewController: UITableViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil
        tableView.delegate = nil
        navigationController?.updateReadOnlyModePrompt()
        
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
                if #available(iOS 13, *) {
                    cell.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
                } else {
                    cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                }
                cell.amountLabel.text = formatter.string(from: personAndAmount.value as NSNumber)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected((key: String, value: Double).self).subscribe(onNext: {
            model in
            if let person = RealmWrapper.shared.people.filter("name == %@", model.key).first {
                self.performSegue(withIdentifier: "showPerson", sender: person)
            }
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            }).disposed(by: disposeBag)
        
//        LTHPasscodeViewController.sharedUser().navigationBarTintColor = UIColor(hex: "4f42fd")
//        LTHPasscodeViewController.sharedUser().navigationTitleColor = UIColor.white
//        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
//        LTHPasscodeViewController.sharedUser().navigationTintColor = UIColor.white
//
//        if LTHPasscodeViewController.doesPasscodeExist() && !UserSettings.readOnlyMode {
//            LTHPasscodeViewController.sharedUser().showLockScreen(withAnimation: true, withLogout: true, andLogoutTitle: nil)
//        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PersonViewController, let person = sender as? Person {
            vc.person = person
        }
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
    
    @IBAction func unwindFromSettings(segue: UIStoryboardSegue) {
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
}

