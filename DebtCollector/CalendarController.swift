import UIKit
import FSCalendar
import RealmSwift
import RxSwift
import RxRealm

class CalendarController: UIViewController {
    @IBOutlet var calendar: FSCalendar!
    
    var allTransactions: Results<GroupTransaction>!
    
    var transactionsByDay: [Int: [GroupTransaction]] = [:]
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        calendar.delegate = self
        calendar.dataSource = self
        allTransactions = RealmWrapper.shared.groupTransactions
        
        Observable.collection(from: allTransactions).bind(onNext: {
            [weak self] results in
            self?.transactionsByDay = [Int: [GroupTransaction]](grouping: Array(results), by: {
                transaction in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
                return components.year! * 10000 + components.month! * 100 + components.day!
            })
        }).disposed(by: disposeBag)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calendar.reloadData()
    }
    
    fileprivate func key(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return components.year! * 10000 + components.month! * 100 + components.day!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailTransactionViewController {
            vc.groupedTransaction = sender as! GroupTransaction
        } else if let vc = segue.destination as? TransactionListViewController {
            vc.date = sender as? Date
        }
    }
}

extension CalendarController : FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let key = self.key(from: date)
        let transactionsOnThatDay = transactionsByDay[key] ?? []
        if transactionsOnThatDay.count == 0 {
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let key = self.key(from: date)
        let transactionsOnThatDay = transactionsByDay[key] ?? []
        if transactionsOnThatDay.count == 1 {
            performSegue(withIdentifier: "showTransaction", sender: transactionsOnThatDay.first!)
        } else if transactionsOnThatDay.count > 1 {
            performSegue(withIdentifier: "showDailyTransactions", sender: date)
        }
        
        calendar.deselect(date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let key = self.key(from: date)
        return transactionsByDay[key]?.count ?? 0
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.setNeedsLayout()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let key = self.key(from: date)
        guard let transactions = transactionsByDay[key] else  {
            return nil
        }
        return transactions.map { $0.transactions.first!.amount < 0 ? .blue : .red }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return self.calendar(calendar, appearance: appearance, eventDefaultColorsFor: date)
    }
}
