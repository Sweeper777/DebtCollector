import RealmSwift
import RxSwift

final class RealmWrapper {
    let transactions: Variable<Results<Transaction>>
    let groupTransactions: Variable<Results<GroupTransaction>>
    private init() {
        let realm = try! Realm()
        transactions = Variable(realm.objects(Transaction.self))
        groupTransactions = Variable(realm.objects(GroupTransaction.self))
    }
    
    static let shared = RealmWrapper()
    
    
}
