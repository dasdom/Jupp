//
//  AppDelegate.swift
//  Jupp
//
//  Created by dasdom on 09.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.tintColor = UIColor(red: 0.206, green: 0.338, blue: 0.586, alpha: 1.000)
        
//        NSUserDefaults.standardUserDefaults().registerDefaults(["hasBeenStartedBefore" : false])
//        
//        let defaultsDict = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
//        println("defaultsDict: \(defaultsDict)")
        
        if NSUserDefaults.standardUserDefaults().boolForKey("hasBeenStartedBefore") == false {
            KeychainAccess.deletePasswortForAccount("AccessToken")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasBeenStartedBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        let postNavigationController = UIStoryboard(name: "Post", bundle: nil).instantiateInitialViewController() as! UINavigationController
        postNavigationController.tabBarItem = UITabBarItem(title: "Post", image: UIImage(named: "compose"), tag: 0)
        
//        let timeLineNavigationController = UIStoryboard(name: "TimeLine", bundle: nil).instantiateInitialViewController() as UINavigationController
//        timeLineNavigationController.tabBarItem = UITabBarItem(title: "Mentions", image: UIImage(named: "mentions"), tag: 1)
//        
//        let tapBarController = UITabBarController()
//        tapBarController.viewControllers = [postNavigationController, timeLineNavigationController]
        
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = postNavigationController
        window?.makeKeyAndVisible()
        
        let urlCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(urlCache)
        return true
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        println("background")
    }

}

