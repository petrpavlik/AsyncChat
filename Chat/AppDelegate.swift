//
//  AppDelegate.swift
//  Chat
//
//  Created by Petr Pavlik on 26/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import LayerKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LYRClientDelegate {

    var window: UIWindow?
    
    let layerClient = LYRClient(appID: NSURL(string: "layer:///apps/staging/aec569e6-80dd-11e5-ba33-6acb000043e7"))


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        layerClient.connectWithCompletion { (success, error) -> Void in
            self.layerClient.requestAuthenticationNonceWithCompletion({ (nonce, error) -> Void in
                self.layerClient.authenticateWithIdentityToken("jICMAO4EXvjHSjj0bpgBnHXMxBn7ufxm6d34Ra6dz3aWas8I") { (authenticatedUserID, error) -> Void in
                    print("authenticated as \(authenticatedUserID)")
                }
            })
        }
        
        return true
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
    }

    func layerClient(client: LYRClient!, didReceiveAuthenticationChallengeWithNonce nonce: String!) {
        
    }

}

