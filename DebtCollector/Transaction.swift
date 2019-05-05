import RealmSwift

class Transaction: Object {
    @objc dynamic var amount: Double = 0.0
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
    @objc dynamic var imageName = ""
}

class Person : Object {
    @objc dynamic var name = ""
}

extension GroupTransaction {
    func image() -> UIImage? {
        if imageName == "" { return nil }
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(imageName).png").path)
        }
        return nil
    }
    
    func deleteImage() {
        if imageName == "" { return }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            fatalError()
        }
        try? FileManager.default.removeItem(at: directory.appendingPathComponent("\(imageName).png"))
    }
}
