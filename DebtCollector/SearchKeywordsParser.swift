import Foundation

struct SearchKeywordsParser {
    
    var delimiterAND: Character = "\""
    var delimiterOR: Character = " "
    
    func parse(string: String) -> [String] {
        var inAnd = false
        var currentKeyword = ""
        var keywords = [String]()
        
        func newKeyword() {
            keywords.append(currentKeyword)
            currentKeyword = ""
        }
        
        for char in string {
            if char == delimiterAND {
                inAnd.toggle()
                newKeyword()
            } else if char == delimiterOR && !inAnd {
                newKeyword()
            } else {
                currentKeyword += "\(char)"
            }
        }
        keywords.append(currentKeyword)
        return keywords.filter { !$0.isEmpty }
    }
}
