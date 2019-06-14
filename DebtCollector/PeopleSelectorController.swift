import UIKit
import RealmSwift

class PeopleSelectorController : UITableViewController {
    
    var selectedPeople = [String]()
    var people: Results<Person>!
    
    override func viewDidLoad() {
        people = RealmWrapper.shared.people.sorted(byKeyPath: "name")
    }
    
}
