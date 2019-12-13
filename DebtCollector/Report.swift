import Foundation

struct Report {

    let totalBorrows: Double
    let totalReturns: Double
    let netBalance: Double
    let transactionCount: Int
    
    let borrowsByPerson: [(String, Double)]
    let returnsByPerson: [(String, Double)]
    
    init(groupTransactions: [GroupTransaction]) {
        let transactions = groupTransactions.flatMap { $0.transactions }
        var partitioned = transactions
        let index = partitioned.partition(by: { ($0.amount.value ?? 0) > 0 })
        let returns = partitioned[..<index]
        let borrows = partitioned[index...]
        totalBorrows = borrows.map({ $0.amount.value ?? 0 }).reduce(0, +)
        totalReturns = abs(returns.map({ $0.amount.value ?? 0 }).reduce(0, +))
        netBalance = totalBorrows - totalReturns
        transactionCount = groupTransactions.count
        
        let borrowsDict = Dictionary(grouping: borrows, by: { $0.personName })
            .mapValues { $0.map({ $0.amount.value ?? 0 }).reduce(0, +) }
        borrowsByPerson = Array(borrowsDict.sorted(by: { $0.value > $1.value }).prefix(5))
        let returnsDict = Dictionary(grouping: returns, by: { $0.personName })
            .mapValues { abs($0.map({ $0.amount.value ?? 0 }).reduce(0, +)) }
        returnsByPerson = Array(returnsDict.sorted(by: { $0.value > $1.value }).prefix(5))
    }
}
