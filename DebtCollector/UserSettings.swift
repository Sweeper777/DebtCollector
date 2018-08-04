import Foundation

final class UserSettings {
    static var detailPresetsForReturning: String {
        get {
            return UserDefaults.standard.string(forKey: "detailPresetsForReturning") ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "detailPresetsForReturning")
        }
    }
    
    static var detailPresetsForBorrowing: String {
        get {
            return UserDefaults.standard.string(forKey: "detailPresetsForBorrowing") ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "detailPresetsForBorrowing")
        }
    }
    
    private init() {}
}
