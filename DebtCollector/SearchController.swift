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
    
    
    private func formTitlePredicateString(keywords: [String]) -> String {
        let terms = Array(repeating: "title CONTAINS %@", count: keywords.count)
        let joinedTerms = terms.joined(separator: " OR ")
        return joinedTerms
    }
    
    private func formDescriptionsPredicateString(keywords: [String]) -> String {
        let terms = Array(repeating: "desc CONTAINS %@", count: keywords.count)
        let joinedTerms = terms.joined(separator: " OR ")
        return joinedTerms
    }
    
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}

let tagKeywords = "keywords"
let tagSearchArea = "searchArea"
