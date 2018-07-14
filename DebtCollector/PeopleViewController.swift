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
    
    @IBAction func addPerson() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let nameField = alert.addTextField("Name")
        alert.showEdit("New Person", subTitle: "Please enter the name of the person:")
        let newPerson = Person()
        newPerson.name = nameField.text!
        try! RealmWrapper.shared.realm.write {
            RealmWrapper.shared.realm.add(newPerson)
        }
    }
}
