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
    
    fileprivate func configureChart(_ chart: BarChartView, labels: [String]) {
        chart.drawValueAboveBarEnabled = false
        chart.xAxis.setLabelCount(labels.count, force: true)
        chart.xAxis.valueFormatter = BarChartXAxisLabelFormatter(labels: labels)
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.enabled = false
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
        
        topBorrowersBarChart.data = topBorrowersChartData
        
        configureChart(topBorrowersBarChart, labels: report.borrowsByPerson.map { $0.0 })
        
        let topReturnersEntries = report.returnsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topReturnersDataSet = BarChartDataSet(entries: topReturnersEntries)
        let topReturnersChartData = BarChartData(dataSet: topReturnersDataSet)
        topReturnersChartData.barWidth = 0.3
        
        topReturnersBarChart.data = topReturnersChartData
        
        configureChart(topReturnersBarChart, labels: report.returnsByPerson.map { $0.0 })
    }
}

class BarChartXAxisLabelFormatter : IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        print(value)
        return labels[Int(value)]
    }
    
    let labels: [String]
    
    init(labels: [String]) {
        self.labels = labels
    }
}
