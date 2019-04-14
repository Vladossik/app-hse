//
//  AppDelegate.swift
//  App_hse
//
//  Created by Vladislava on 16/01/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import SwiftyVK

var vkDelegateReference : SwiftyVKDelegate?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storageManager = StorageManager(coreDataStack: CoreDataStack(resourceName: "Model"))

    @available(iOS 9.0, *)
    private func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let app = options[.sourceApplication] as? String
        VK.handle(url: url, sourceApplication: app)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        vkDelegateReference = VKDelegate()
        VK.setUp(appId: "6849870", delegate: vkDelegateReference!)
        //(vkDelegateReference as! VKDelegate).silentLogin()
        
        // Set application version into Settings.bundle
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let versionString = String(format: "%@ (%@)", version, build)
        
        let userDefaults = UserDefaults.standard
        //print(userDefaults.stringForKey("version"))
        userDefaults.set(versionString, forKey: "version")
        userDefaults.synchronize()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VK.handle(url: url, sourceApplication: sourceApplication)
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

    private func skipLogin() {
        let bundle = Bundle.main
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: bundle).instantiateViewController(withIdentifier: "SWRevealViewController")
        window?.makeKeyAndVisible()
    }
    
    
}

