import Foundation

final class UserSettings {
    static var detailPresets: String {
        get {
            return UserDefaults.standard.string(forKey: "detailPresets") ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "detailPresets")
        }
    }
    
    private init() {}
}
