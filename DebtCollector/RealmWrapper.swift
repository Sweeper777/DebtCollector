import RealmSwift
import RxSwift

final class RealmWrapper {
    let transactions: Results<Transaction>
    let groupTransactions: Results<GroupTransaction>
    let people: Results<Person>
    let realm: Realm!
    
    private init() {
        do {
            realm = try Realm()
            transactions = realm.objects(Transaction.self)
            groupTransactions = realm.objects(GroupTransaction.self)
            people = realm.objects(Person.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
    static let shared = RealmWrapper()
    
    
}
