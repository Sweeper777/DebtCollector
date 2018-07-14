import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class PeopleViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        RealmWrapper.shared.people.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) {
                index, person, cell in
                cell.textLabel?.text = person.name
        }.disposed(by: disposeBag)
    }
    
}
