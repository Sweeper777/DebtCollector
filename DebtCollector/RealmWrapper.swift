import RealmSwift
import RxSwift

final class RealmWrapper {
    let transactions: Variable<Results<Transaction>>
    let groupTransactions: Variable<Results<GroupTransaction>>
    let people: Variable<Results<Person>>
    let realm: Realm!
    
    private init() {
        realm = try! Realm()
        transactions = Variable(realm.objects(Transaction.self))
        groupTransactions = Variable(realm.objects(GroupTransaction.self))
        people = Variable(realm.objects(Person.self))
    }
    
    static let shared = RealmWrapper()
    
    
}
