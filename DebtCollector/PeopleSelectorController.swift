import UIKit
import RealmSwift

class PeopleSelectorController : UITableViewController {
    
    var selectedPeople = [String]()
    var people: Results<Person>!
    
    override func viewDidLoad() {
        people = RealmWrapper.shared.people.sorted(byKeyPath: "name")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
}
