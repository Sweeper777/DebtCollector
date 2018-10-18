import UIKit

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
    
    static var showDetailPresetsOnBorrow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showDetailPresetsOnBorrow")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "showDetailPresetsOnBorrow")
        }
    }
    
    static var currencySymbol: String? {
        get {
            return UserDefaults.standard.string(forKey: "currencySymbol")
        }
        
        set {
            if newValue?.trimmed() != "" {
                UserDefaults.standard.set(newValue, forKey: "currencySymbol")
            } else {
                UserDefaults.standard.set(nil, forKey: "currencySymbol")
            }
        }
    }
    private init() {}
}
