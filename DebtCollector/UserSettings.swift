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
    
    static var showPresetsWhenBorrowing : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showPresetsWhenBorrowing")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "showPresetsWhenBorrowing")
        }
    }
    
    static var showPresetsWhenReturning : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showPresetsWhenReturning")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "showPresetsWhenReturning")
        }
    }
    
    private init() {}
}
