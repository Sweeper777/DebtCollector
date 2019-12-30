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
        
    }
}

let tagKeywords = "keywords"
let tagSearchArea = "searchArea"
