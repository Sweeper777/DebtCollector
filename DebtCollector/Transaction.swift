import RealmSwift

class Transaction: Object {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var personName = ""
    @objc dynamic var date = Date()
    @objc dynamic var details = ""
    let parentTransactions = LinkingObjects(fromType: GroupTransaction.self, property: "transactions")
}

class GroupTransaction: Object {
    @objc dynamic var title = ""
    let transactions = List<Transaction>()
}

class Person : Object {
    @objc dynamic var name = ""
}
