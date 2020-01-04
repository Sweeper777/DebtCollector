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
        let keywords = ((values[tagKeywords] as? String) ?? "").components(separatedBy: " ").filter { $0.isNotEmpty }
        let titlePredicate = formTitlePredicateString(keywords: keywords)
        let descriptionPredicate = formDescriptionsPredicateString(keywords: keywords)
        let detailsPredicate = formDetailsPredicateString(keywords: keywords)
        let searchInTitles = (values[tagSearchInTitles] as? Bool) ?? false
        let searchInDescriptions = (values[tagSearchInDescriptions] as? Bool) ?? false
        let searchInDetails = (values[tagSearchInDetails] as? Bool) ?? false
        
        if !searchInTitles && !searchInDescriptions && !searchInDetails {
            return .init(value: false)
        }
        
        var clausesCount = 0
        var predicateFormat = ""
        if searchInTitles {
            predicateFormat += "(\(titlePredicate)) OR "
            clausesCount += 1
        }
        if searchInDescriptions {
            predicateFormat += "(\(descriptionPredicate)) OR "
            clausesCount += 1
        }
        if searchInDetails {
            predicateFormat += "(\(detailsPredicate)) OR "
            clausesCount += 1
        }
        predicateFormat += "FALSEPREDICATE"
        let substitution = Array(repeating: keywords, count: clausesCount).flatMap { $0 }
        return NSPredicate(format: predicateFormat, argumentArray: substitution)
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
let tagSearchInTitles = "searchInTitles"
let tagSearchInDescriptions = "searchInDescriptions"
let tagSearchInDetails = "searchInDetails"
