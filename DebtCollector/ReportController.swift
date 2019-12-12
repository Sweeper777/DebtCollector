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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = UserSettings.currencySymbol
        formatter.numberStyle = .currency
        
        totalBorrowingsLabel.text = formatter.string(from: report.totalBorrows as NSNumber)
        totalReturnsLabel.text = formatter.string(from: report.totalReturns as NSNumber)
        netBalanceLabel.text = formatter.string(from: abs(report.netBalance) as NSNumber)
        netBalanceTextLabel.text = report.netBalance > 0 ? "Net Borrowings" : "Net Returns"
        
        let topBorrowersEntries = report.borrowsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topBorrowersDataSet = BarChartDataSet(entries: topBorrowersEntries)
        let topBorrowersChartData = BarChartData(dataSet: topBorrowersDataSet)
        topBorrowersChartData.barWidth = 0.3
        
        topBorrowersBarChart.data = topBorrowersChartData
        
        topBorrowersBarChart.drawValueAboveBarEnabled = false
        topBorrowersBarChart.xAxis.setLabelCount(report.borrowsByPerson.count, force: true)
        topBorrowersBarChart.xAxis.valueFormatter = BarChartXAxisLabelFormatter(labels: report.borrowsByPerson.map { $0.0 })
        topBorrowersBarChart.xAxis.labelPosition = .bottom
        topBorrowersBarChart.xAxis.drawGridLinesEnabled = false
        topBorrowersBarChart.leftAxis.enabled = false
        topBorrowersBarChart.rightAxis.enabled = false
        topBorrowersBarChart.legend.enabled = false
        topBorrowersBarChart.xAxis.granularityEnabled = true
        topBorrowersBarChart.xAxis.granularity = 1
        
    }
}

