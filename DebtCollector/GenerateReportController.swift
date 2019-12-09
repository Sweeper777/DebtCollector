import UIKit
import Eureka
import RealmSwift

class GenerateReportController: FormViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
