import Foundation

struct SearchKeywordsParser {
    
    var delimiterAND: Character = "\""
    var delimiterOR: Character = " "
    
    func parse(string: String) -> [String] {
        var inAnd = false
        var currentKeyword = ""
        var keywords = [String]()
        
    }
}
