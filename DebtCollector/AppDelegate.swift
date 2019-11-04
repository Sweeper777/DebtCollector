import UIKit
import SwiftyUtils
import Eureka
import Firebase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = UIColor(hex: "4f42fd")
        NavigationAccessoryView.appearance().tintColor = UIColor(hex: "3b7b3b")
        FirebaseApp.configure()
        
        let fileManager = FileManager.default
        
        //Cache original realm path (documents directory)
        guard let originalDefaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL?.path else {
            return true
        }
        
        //Generate new realm path based on app group
        let appGroupURL: URL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.io.github.sweeper777.DebtCollectorGroup")!
        let realmPath = appGroupURL.appendingPathComponent("default.realm").path
        
        //Moves the realm to the new location if it hasn't been done previously
        if (fileManager.fileExists(atPath: originalDefaultRealmPath) && !fileManager.fileExists(atPath: realmPath)) {
            do {
                try fileManager.moveItem(atPath: originalDefaultRealmPath, toPath: realmPath)
            } catch {
                print(error)
            }
        }
        
        //Set the realm path to the new directory
        let config = Realm.Configuration(
            fileURL: URL(string: realmPath),
            schemaVersion: 5,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 4) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

