import UIKit
import Eureka

class SearchController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("keywords") <<< TextRow(tagKeywords) {
            row in
            row.cell.textField.smartQuotesType = .no
        }
        
        form +++ Section("search in")
        <<< SwitchRow(tagSearchInTitles) {
            row in
            row.title = "Titles"
            row.value = !UserSettings.searchInTitles
        }.onChange({ (row) in
            UserSettings.searchInTitles = !row.value!
        })
            
        <<< SwitchRow(tagSearchInDescriptions) {
            row in
            row.title = "Descriptions"
            row.value = !UserSettings.searchInDescriptions
        }.onChange({ (row) in
            UserSettings.searchInDescriptions = !row.value!
        })
            
        <<< SwitchRow(tagSearchInDetails) {
            row in
            row.title = "Details"
            row.value = !UserSettings.searchInDetails
        }.onChange({ (row) in
            UserSettings.searchInDetails = !row.value!
        })
        
        form +++ Section("select range")
        <<< PickerInlineRow<String>(tagRange) {
            row in
            row.title = "Range"
            row.options = [last7Days, last14Days, last30Days, last90Days, last365Days, allTime, custom]
            row.value = last7Days
        }
        
        <<< DateInlineRow(tagStartDate) {
            row in
            row.title = "From"
            row.value = Date().addingTimeInterval(-86400 * 7)
            row.hidden = .function([tagRange], { ($0.rowBy(tag: tagRange) as! RowOf<String>).value != custom })
        }
        
        <<< DateInlineRow(tagEndDate) {
            row in
            row.title = "To"
            row.value = Date()
            row.hidden = .function([tagRange], { ($0.rowBy(tag: tagRange) as! RowOf<String>).value != custom })
        }
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func formKeywordPredicate() -> NSPredicate {
        let values = form.values()
        let keywords = SearchKeywordsParser().parse(string: (values[tagKeywords] as? String) ?? "")
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
    
    func formDatePredicate() -> NSPredicate {
        let values = form.values()
        let dateRange = values[tagRange] as? String
        if dateRange == custom {
            let start = (self.form.rowBy(tag: tagStartDate) as! RowOf<Date>).value!
            let end = (self.form.rowBy(tag: tagEndDate) as! RowOf<Date>).value!
            if start < end {
                return NSPredicate(format: "date BETWEEN {%@, %@}", start as NSDate, end as NSDate)
            } else {
                return NSPredicate(value: false)
            }
        } else if dateRange == allTime {
            return NSPredicate(value: true)
        } else {
            let dict = [
                last7Days: 7,
                last14Days: 14,
                last30Days: 30,
                last90Days: 90,
                last365Days: 365
            ]
            let end = Date()
            let start = end.addingTimeInterval(-86400 * Double(dict[dateRange!]!))
            return NSPredicate(format: "date BETWEEN {%@, %@}", start as NSDate, end as NSDate)
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
        self.performSegue(withIdentifier: "showResults", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchResultsController {
            vc.keywordPredicate = formKeywordPredicate()
            vc.datePredicate = formDatePredicate()
        }
    }
}

let tagKeywords = "keywords"
let tagSearchInTitles = "searchInTitles"
let tagSearchInDescriptions = "searchInDescriptions"
let tagSearchInDetails = "searchInDetails"
