import UIKit
import NotificationCenter
import RealmSwift
import EmptyDataSet_Swift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var tableView: UITableView!
    var peopleAndAmounts: [(key: String, value: Double)] = []
    var displayedItemCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TodayTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "You have no debtors!"))
            view.shouldDisplay(true)
        }
        
        var config = Realm.Configuration()
        config.schemaVersion = 4
        config.fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.github.sweeper777.DebtCollectorGroup")!.appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        reload()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            displayedItemCount = 3
            preferredContentSize = CGSize(width: 0, height: 243)
        } else {
            displayedItemCount = 1
            preferredContentSize = CGSize(width: 0, height: 81)
        }
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
        reload()
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TodayTableCell
        let personAndAmount = peopleAndAmounts[indexPath.row]
        cell.nameLabel.text = personAndAmount.key
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        cell.amountLabel.text = formatter.string(from: personAndAmount.value as NSNumber)
        return cell
    }
}
