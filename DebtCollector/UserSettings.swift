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
    
    static var showDetailPresetsOnReturn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showDetailPresetsOnReturn")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "showDetailPresetsOnReturn")
        }
    }
    
    private init() {}
}
