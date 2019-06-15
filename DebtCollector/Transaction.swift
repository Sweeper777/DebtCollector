import RealmSwift

class Transaction: Object {
    let amount = RealmOptional<Double>()
    @objc dynamic var personName = ""
    @objc dynamic var details = ""
    @objc dynamic var date = Date()
    let parentTransactions = LinkingObjects(fromType: GroupTransaction.self, property: "transactions")
}

class GroupTransaction: Object {
    @objc dynamic var title = ""
    @objc dynamic var date = Date()
    let transactions = List<Transaction>()
    
    @objc dynamic var desc = ""
}

class Person : Object {
    @objc dynamic var name = ""
}
