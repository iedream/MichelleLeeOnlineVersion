//
//  AppDelegate.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-07.
//  Copyright © 2015 Catherine. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var internetReach:Reachability?
    var restrictRotation:Bool = true


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Populate Playist from Plist
        Variables.sharedInstance.populatePlayListFromPlist("ModifiedPlayist.plist")
        
        // Set Up Check For Connection
        self.internetReach = Reachability.reachabilityForInternetConnection()
        self.internetReach?.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkForReachability:", name: kReachabilityChangedNotification, object: nil)
        
        // Check For Connection
        self.checkStatus((self.internetReach?.currentReachabilityStatus())!)
        
        return true
    }
    
    func checkForReachability(notification:NSNotification){
        self.internetReach = notification.object as? Reachability
        let myNetWorkStatus:NetworkStatus = (self.internetReach?.currentReachabilityStatus()
        )!
        self.checkStatus(myNetWorkStatus)
    }
    
    // Actually Populate Connection Variable
    func checkStatus(currentNetWork:NetworkStatus){
        if(currentNetWork.rawValue == NotReachable.rawValue){
            sourceMethods.sharedInstance.setCurrentConnectState(ConnectionState.NONE)
        }else if(currentNetWork.rawValue == ReachableViaWiFi.rawValue){
            sourceMethods.sharedInstance.setCurrentConnectState(ConnectionState.WIFI);
            
        }else if(currentNetWork.rawValue == ReachableViaWWAN.rawValue){
            sourceMethods.sharedInstance.setCurrentConnectState(ConnectionState.WWAN);
        }
    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if(self.restrictRotation){
            return UIInterfaceOrientationMask.Portrait
        }
        return UIInterfaceOrientationMask.All
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
    }


}

