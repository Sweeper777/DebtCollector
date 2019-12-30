import UIKit
import Eureka

class SearchController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("keywords") <<< TextRow(tagKeywords) {
            row in
        }
        
        form +++ Section("search in") <<< SegmentedRow<String>(tagSearchArea) {
            row in
            row.options = ["Titles", "Descriptions", "Details", "Everywhere"]
            row.value = "Everywhere"
        }
        
        form +++ ButtonRow {
            row in
            row.title = "Search"
        }
        .onCellSelection({ (cell, row) in
            
        })
    }
    
    }
}

let tagKeywords = "keywords"
let tagSearchArea = "searchArea"
