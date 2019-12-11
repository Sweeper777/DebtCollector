import UIKit
import Charts

class ReportController : UITableViewController {
    
    var report: Report!
    
    @IBOutlet var totalBorrowingsLabel: UILabel!
    @IBOutlet var totalReturnsLabel: UILabel!
    @IBOutlet var netBalanceLabel: UILabel!
    @IBOutlet var netBalanceTextLabel: UILabel!
    @IBOutlet var topBorrowersBarChart: BarChartView!
    @IBOutlet var topReturnersBarChart: BarChartView!
    
}

