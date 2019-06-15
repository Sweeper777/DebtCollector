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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if selectedPeople.contains(people[indexPath.row].name) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedPeople.firstIndex(of: people[indexPath.row].name) {
            _ = selectedPeople.remove(at: index)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            selectedPeople.append(people[indexPath.row].name)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next() {
        performSegue(withIdentifier: "showNewTransaction", sender: selectedPeople)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NewTransactionViewController,
            let selectedPeople = sender as? [String] {
            vc.personNamesAlreadyFilledIn = selectedPeople.sorted()
        }
    }
}
