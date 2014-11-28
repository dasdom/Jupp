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

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
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
        
        let postNavigationController = UIStoryboard(name: "Post", bundle: nil).instantiateInitialViewController() as UINavigationController
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

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

