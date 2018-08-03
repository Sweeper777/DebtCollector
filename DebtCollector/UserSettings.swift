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
    
    private init() {}
}
