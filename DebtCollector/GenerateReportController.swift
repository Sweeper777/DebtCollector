import UIKit
import Eureka
import RealmSwift

class GenerateReportController: FormViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = Section("select range")
        section <<< PickerInlineRow<String>(tagRange) {
            row in
            row.title = "Range"
            row.options = [last7Days, last14Days, last30Days, last90Days, last365Days, allTime, custom]
            row.value = last7Days
        }
        
    }

// MARK: Date Range Options

fileprivate let last7Days = "Last 7 Days"
fileprivate let last14Days = "Last 14 Days"
fileprivate let last30Days = "Last 30 Days"
fileprivate let last90Days = "Last 90 Days"
fileprivate let last365Days = "Last 365 Days"
fileprivate let allTime = "All Time"
fileprivate let custom = "Custom"

// MARK: Form Tags

fileprivate let tagRange = "range"
fileprivate let tagStartDate = "startDate"
fileprivate let tagEndDate = "endDate"
