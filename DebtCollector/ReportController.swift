import UIKit
import Charts

class ReportController : UITableViewController {
    
    var report: Report!
    
    @IBOutlet var totalTransactionsLabel: UILabel!
    @IBOutlet var totalBorrowingsLabel: UILabel!
    @IBOutlet var totalReturnsLabel: UILabel!
    @IBOutlet var netBalanceLabel: UILabel!
    @IBOutlet var netBalanceTextLabel: UILabel!
    @IBOutlet var topBorrowersBarChart: BarChartView!
    @IBOutlet var topReturnersBarChart: BarChartView!
    
    fileprivate func configureChart(_ chart: BarChartView) {
        chart.drawValueAboveBarEnabled = false
        chart.xAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.xAxis.granularityEnabled = true
        chart.xAxis.granularity = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = UserSettings.currencySymbol
        formatter.numberStyle = .currency
        
        totalTransactionsLabel.text = "\(report.transactionCount)"
        totalBorrowingsLabel.text = formatter.string(from: report.totalBorrows as NSNumber)
        totalReturnsLabel.text = formatter.string(from: report.totalReturns as NSNumber)
        netBalanceLabel.text = formatter.string(from: abs(report.netBalance) as NSNumber)
        netBalanceTextLabel.text = report.netBalance > 0 ? "Net Borrowings" : "Net Returns"
        
        let topBorrowersEntries = report.borrowsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topBorrowersDataSet = BarChartDataSet(entries: topBorrowersEntries)
        let topBorrowersChartData = BarChartData(dataSet: topBorrowersDataSet)
        topBorrowersChartData.barWidth = 0.3
        topBorrowersChartData.setValueFormatter(BarChartLabelFormatter(labels: report.borrowsByPerson.map { $0.0 }))
        
        topBorrowersBarChart.data = topBorrowersChartData
        configureChart(topBorrowersBarChart)
        
        let topReturnersEntries = report.returnsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topReturnersDataSet = BarChartDataSet(entries: topReturnersEntries)
        let topReturnersChartData = BarChartData(dataSet: topReturnersDataSet)
        topReturnersChartData.barWidth = 0.3
        topReturnersChartData.setValueFormatter(BarChartLabelFormatter(labels: report.returnsByPerson.map { $0.0 }))
        
        topReturnersBarChart.data = topReturnersChartData
        configureChart(topReturnersBarChart)
    }
}

class BarChartLabelFormatter : IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return labels[Int(entry.x)]
    }
    
    let labels: [String]
    
    init(labels: [String]) {
        self.labels = labels
    }
}
