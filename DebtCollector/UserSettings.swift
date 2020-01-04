import UIKit

final class UserSettings {
    static let sharedDefaults = UserDefaults.init(suiteName: "group.io.github.sweeper777.DebtCollectorGroup")!
    
    static var detailPresets: String {
        get {
            return UserDefaults.standard.string(forKey: "detailPresets") ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "detailPresets")
        }
    }
    
    static var titlePresets: String {
        get {
            return UserDefaults.standard.string(forKey: "titlePresets") ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "titlePresets")
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
            return sharedDefaults.string(forKey: "currencySymbol")
        }
        
        set {
            if newValue?.trimmed() != "" {
                sharedDefaults.set(newValue, forKey: "currencySymbol")
            } else {
                sharedDefaults.set(nil, forKey: "currencySymbol")
            }
        }
    }
    
    static var bgImage: UIImage? {
        get {
            return UserDefaults.standard.data(forKey: "bgImage").map(UIImage.init) ?? nil
        }
        
        set {
            UserDefaults.standard.set(newValue?.pngData(), forKey: "bgImage")
        }
    }
    
    /// MARK: Search Option Settings
    // NOTE: the NOT of these values are the switch values
    
    static var searchInTitles: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "searchInTitles")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "searchInTitles")
        }
    }
    
    static var searchInDescriptions: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "searchInDescriptions")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "searchInDescriptions")
        }
    }
    
    static var searchInDetails: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "searchInDetails")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "searchInDetails")
        }
    }
    
    private init() {}
}
