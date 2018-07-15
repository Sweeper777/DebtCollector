import RealmSwift
import RxSwift

final class RealmWrapper {
    let transactions: Results<Transaction>
    let groupTransactions: Results<GroupTransaction>
    let people: Results<Person>
    let realm: Realm!
    
    private init() {
        realm = try! Realm()
        transactions = realm.objects(Transaction.self)
        groupTransactions = realm.objects(GroupTransaction.self)
        people = realm.objects(Person.self)
    }
    
    static let shared = RealmWrapper()
    
    
}
