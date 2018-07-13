import RealmSwift

class Transaction: Object {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var name = ""
}

class GroupTransaction: Object {
    @objc dynamic var title = ""
    @objc dynamic var details = ""
    let value = List<Transaction>()

class Person : Object {
    @objc dynamic var name = ""
}
