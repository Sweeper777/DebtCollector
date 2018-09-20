import UIKit
import FSCalendar
import RealmSwift
import RxSwift
import RxRealm

class CalendarController: UIViewController {
    @IBOutlet var calendar: FSCalendar!
    
    let allTransactions = RealmWrapper.shared.realm.objects(GroupTransaction.self)
    
    var transactionsByDay: [Int: [GroupTransaction]] = [:]
    
    let disposeBag = DisposeBag()
}
