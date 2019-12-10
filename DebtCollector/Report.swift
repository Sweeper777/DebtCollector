import Foundation

struct Report {

    let totalBorrows: Double
    let totalReturns: Double
    let netBalance: Double
    
    let borrowsByPerson: [(String, Double)]
    let returnsByPerson: [(String, Double)]
    
}
