import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var tableView: UITableView!
    var peopleAndAmounts: [(key: String, value: Double)] = []
    var displayedItemCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        var config = Realm.Configuration()
        config.schemaVersion = 4
        config.fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.github.sweeper777.DebtCollectorGroup")!.appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        reload()
    }
    func reload() {
        peopleAndAmounts = aggregateTransactionAndPeople(
            transactions: RealmWrapper.shared.transactions, people: RealmWrapper.shared.people)
        tableView.reloadData()
    }
    
    func aggregateTransactionAndPeople(transactions: Results<Transaction>, people: Results<Person>) -> [(key: String, value: Double)] {
        var peopleDict = people.reduce(into: [String: Double](), { $0[$1.name] = 0 })
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
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
