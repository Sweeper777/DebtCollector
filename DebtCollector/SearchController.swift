import UIKit
import Eureka

class SearchController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("keywords") <<< TextRow(tagKeywords) {
            row in
        }
        
        form +++ Section("search in")
        <<< SwitchRow(tagSearchInTitles) {
            row in
            row.title = "Titles"
            row.value = true
        }
        <<< SwitchRow(tagSearchInDescriptions) {
            row in
            row.title = "Descriptions"
            row.value = true
        }
        <<< SwitchRow(tagSearchInDetails) {
            row in
            row.title = "Details"
            row.value = true
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func formPredicate() -> NSPredicate {
        let values = form.values()
        let keywords = ((values[tagKeywords] as? String) ?? "").trimmed().components(separatedBy: " ")
        let titlePredicate = formTitlePredicateString(keywords: keywords)
        let descriptionPredicate = formDescriptionsPredicateString(keywords: keywords)
        let detailsPredicate = formDetailsPredicateString(keywords: keywords)
        let searchArea = values[tagSearchArea] as! String
        switch searchArea {
        case "in Titles":
            return NSPredicate(format: titlePredicate, argumentArray: keywords)
        case "in Descriptions":
            return NSPredicate(format: descriptionPredicate, argumentArray: keywords)
        case "in Details":
            return NSPredicate(format: detailsPredicate, argumentArray: keywords)
        case "Everywhere":
            let everywherePredicate = "(\(titlePredicate)) OR (\(descriptionPredicate)) OR (\(detailsPredicate))"
            let substitution = keywords + keywords + keywords
            return NSPredicate(format: everywherePredicate, argumentArray: substitution)
        default:
            fatalError()
        }
    }
    
    private func formTitlePredicateString(keywords: [String]) -> String {
        return formGeneralPredicateString(keywords: keywords,
                                          containsClauseLeftOperand: "title",
                                          joinedTermsFormat: "%@")
    }
    
    private func formDescriptionsPredicateString(keywords: [String]) -> String {
        return formGeneralPredicateString(keywords: keywords,
                                          containsClauseLeftOperand: "desc",
                                          joinedTermsFormat: "%@")
    }
    
    private func formDetailsPredicateString(keywords: [String]) -> String {
        return formGeneralPredicateString(keywords: keywords,
                                          containsClauseLeftOperand: "$transaction.details",
                                          joinedTermsFormat: "SUBQUERY(transactions, $transaction, %@) .@count > 0")
    }
    
    private func formGeneralPredicateString(keywords: [String], containsClauseLeftOperand: String, joinedTermsFormat: String) -> String {
        let terms = Array(repeating: "\(containsClauseLeftOperand) CONTAINS[c] %@", count: keywords.count)
        let joinedTerms = terms.joined(separator: " OR ")
        return String(format: joinedTermsFormat, joinedTerms)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func search() {
        self.performSegue(withIdentifier: "showResults", sender: self.formPredicate())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchResultsController, let predicate = sender as? NSPredicate {
            vc.predicate = predicate
        }
    }
}

let tagKeywords = "keywords"
let tagSearchArea = "searchArea"
