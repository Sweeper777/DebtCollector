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
    
    func formPredicate() -> NSPredicate {
        let values = form.values()
        let keywords = (values[tagKeywords] as! String).split(separator: " ").map(String.init)
        let titlePredicate = formTitlePredicateString(keywords: keywords)
        let descriptionPredicate = formDescriptionsPredicateString(keywords: keywords)
        let detailsPredicate = formDetailsPredicateString(keywords: keywords)
        let searchArea = values[tagSearchArea] as! String
        switch searchArea {
        case "Titles":
            return NSPredicate(format: titlePredicate, argumentArray: keywords)
        case "Descriptions":
            return NSPredicate(format: descriptionPredicate, argumentArray: keywords)
        case "Details":
            return NSPredicate(format: detailsPredicate, argumentArray: keywords)
        case "Everywhere":
            let everywherePredicate = "(\(titlePredicate) OR (\(descriptionPredicate)) OR (\(detailsPredicate))"
            let substitution = keywords + keywords + keywords
            return NSPredicate(format: everywherePredicate, argumentArray: substitution)
        default:
            fatalError()
        }
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
    
    private func formDetailsPredicateString(keywords: [String]) -> String {
        let terms = Array(repeating: "$transaction.details CONTAINS %@", count: keywords.count)
        let joinedTerms = terms.joined(separator: " OR ")
        return "SUBQUERY(transactions, $transaction, \(joinedTerms)) .@count > 0"
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}

let tagKeywords = "keywords"
let tagSearchArea = "searchArea"
