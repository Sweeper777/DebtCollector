import UIKit
import NotificationCenter
import RealmSwift
import EmptyDataSet_Swift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var blur: UIVisualEffectView!
    var peopleAndAmounts: [(key: String, value: Double)] = []
    static let collapsedStateItemCount = 3
    static let expandedStateItemCount = 6
    var displayedItemCount = collapsedStateItemCount
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TodayTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "You have no debtors!"))
            view.shouldDisplay(true)
        }
        
        if #available(iOSApplicationExtension 13.0, *) {
            blur.effect = UIVibrancyEffect.widgetEffect(forVibrancyStyle: .label)
        } else {
            blur.effect = UIVibrancyEffect.widgetPrimary()
        }
        
        var config = Realm.Configuration()
        config.schemaVersion = 4
        config.fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.github.sweeper777.DebtCollectorGroup")!.appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        reload()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            displayedItemCount = min(TodayViewController.expandedStateItemCount, peopleAndAmounts.count)
        } else {
            displayedItemCount = min(TodayViewController.collapsedStateItemCount, peopleAndAmounts.count)
        }
        reload()
        preferredContentSize = CGSize(width: 0, height: 44 * displayedItemCount)
    }
    
    func reload() {
        peopleAndAmounts = aggregateTransactionAndPeople(
            transactions: RealmWrapper.shared.transactions, people: RealmWrapper.shared.people)
        tableView.reloadData()
        if peopleAndAmounts.count > TodayViewController.collapsedStateItemCount {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        }
    }
    
    func aggregateTransactionAndPeople(transactions: Results<Transaction>, people: Results<Person>) -> [(key: String, value: Double)] {
        var peopleDict = people.reduce(into: [String: Double](), { $0[$1.name] = 0 })
        for transaction in transactions {
            if peopleDict[transaction.personName] != nil {
                peopleDict[transaction.personName]! += transaction.amount.value ?? 0
            }
        }
        let mapped = peopleDict.filter { $0.value > 0 }.map({ (x) in
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
        return min(displayedItemCount, peopleAndAmounts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TodayTableCell
        let personAndAmount = peopleAndAmounts[indexPath.row]
        cell.nameLabel.text = personAndAmount.key
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = UserDefaults(suiteName: "group.io.github.sweeper777.DebtCollectorGroup")?.string(forKey: "currencySymbol")
        cell.amountLabel.text = "owes you \(formatter.string(from: personAndAmount.value as NSNumber)!)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extensionContext?.open(URL(string: "debtcollector://")!, completionHandler: nil)
    }
}
