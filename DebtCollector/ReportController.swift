import UIKit
import Charts

class ReportController : UITableViewController {
    
    var report: Report!
    
    @IBOutlet var totalTransactionsLabel: UILabel!
    @IBOutlet var totalBorrowingsLabel: UILabel!
    @IBOutlet var totalReturnsLabel: UILabel!
    @IBOutlet var borrowingsCountLabel: UILabel!
    @IBOutlet var returnsCountLabel: UILabel!
    @IBOutlet var netBalanceLabel: UILabel!
    @IBOutlet var netBalanceTextLabel: UILabel!
    @IBOutlet var topBorrowersBarChart: BarChartView!
    @IBOutlet var topReturnersBarChart: BarChartView!
    
    fileprivate func configureChart(_ chart: BarChartView) {
        chart.xAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.xAxis.granularityEnabled = true
        chart.xAxis.granularity = 1
        chart.highlightFullBarEnabled = false
        chart.highlightPerTapEnabled = false
        chart.highlightPerDragEnabled = false
        chart.barData?.barWidth = 0.3
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.fitBars = true
        chart.dragEnabled = false
        if #available(iOS 13.0, *) {
            chart.barData?.setValueTextColor(.label)
            chart.leftAxis.labelTextColor = .label
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = UserSettings.currencySymbol
        formatter.numberStyle = .currency
        
        totalTransactionsLabel.text = "\(report.transactionCount)"
        borrowingsCountLabel.text = "\(report.borrowCount)"
        returnsCountLabel.text = "\(report.returnCount)"
        totalBorrowingsLabel.text = formatter.string(from: report.totalBorrows as NSNumber)
        totalReturnsLabel.text = formatter.string(from: report.totalReturns as NSNumber)
        netBalanceLabel.text = formatter.string(from: abs(report.netBalance) as NSNumber)
        netBalanceTextLabel.text = report.netBalance > 0 ? "Net Borrowings" : "Net Returns"
        
        let topBorrowersEntries = report.borrowsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topBorrowersDataSet = BarChartDataSet(entries: topBorrowersEntries)
        topBorrowersDataSet.setColor(UIColor.red.darker())
        let topBorrowersChartData = BarChartData(dataSet: topBorrowersDataSet)
        topBorrowersChartData.setValueFormatter(BarChartLabelFormatter(labels: report.borrowsByPerson.map { $0.0 }))
        
        topBorrowersBarChart.data = topBorrowersChartData
        configureChart(topBorrowersBarChart)
        
        let topReturnersEntries = report.returnsByPerson.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.1) }
        let topReturnersDataSet = BarChartDataSet(entries: topReturnersEntries)
        topReturnersDataSet.setColor(UIColor.green.darker())
        let topReturnersChartData = BarChartData(dataSet: topReturnersDataSet)
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
