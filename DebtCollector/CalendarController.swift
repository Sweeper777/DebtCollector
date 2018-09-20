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
    
    override func viewDidLoad() {
        calendar.delegate = self
        calendar.dataSource = self
        
        Observable.collection(from: allTransactions).bind(onNext: {
            [weak self] results in
            self?.transactionsByDay = [Int: [GroupTransaction]](grouping: Array(results), by: {
                transaction in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
                return components.year! * 1000 + components.month! * 100 + components.day!
            })
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calendar.reloadData()
    }
    
}
