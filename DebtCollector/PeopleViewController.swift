import UIKit
import RxSwift
import RxCocoa
import SCLAlertView
import RxRealm

class PeopleViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        tableView.delegate = nil
        Observable.collection(from: RealmWrapper.shared.people)
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) {
                index, person, cell in
                cell.textLabel?.text = person.name
        }.disposed(by: disposeBag)
    }
    
    @IBAction func addPerson() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let nameField = alert.addTextField("Name")
        alert.addButton("OK", action: {
            let newPerson = Person()
            newPerson.name = nameField.text!
            try! RealmWrapper.shared.realm.write {
                RealmWrapper.shared.realm.add(newPerson)
            }
        })
        alert.addButton("Cancel", action: {})
        alert.showEdit("New Person", subTitle: "Please enter the name of the person:")
        
    }
}
