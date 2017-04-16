//
//  AppDelegate.swift
//  Longplay
//
//  Created by Joe Nguyen on 30/05/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let spotifySession = SpotifySession()
    var loginViewController:LoginViewController?
    var masterViewController:MasterViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame:UIScreen.main.bounds)
        if let window = self.window {
            let launchViewController = LaunchViewController()
            window.rootViewController = launchViewController
            window.makeKeyAndVisible()
            
            spotifySession.setup {
                (session:SPTSession?,didLogin:Bool) -> () in
                if !didLogin {
                    self.transitionToLoginViewController()
                } else {
                    self.transitionToMasterViewController(session)
                }
            }
        }
        application.isStatusBarHidden = true
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if (SPTAuth.defaultInstance().canHandle(url)) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url,
                                                         callback: { (error: Error?, session: SPTSession?) in
                                                            self.handleAuthCallback(session, error: error as NSError?)
            })
        }
        return false
    }
    
    func handleAuthCallback(_ session:SPTSession?, error:NSError?) {
        
        spotifySession.handleAuthCallback(session, error: error) { (session) -> () in
            self.transitionToMasterViewController(session)
            if let loginViewController = self.loginViewController,
                let masterViewController = self.masterViewController{
                    UIView.transition(from: loginViewController.view,
                        to: masterViewController.view,
                        duration: 0.5,
                        options: UIViewAnimationOptions.transitionCrossDissolve,
                        completion: nil)
            }
        }
    }
    
    // MARK: Transitions
    
    func transitionToLoginViewController() {
        
        if let window = self.window {
            self.loginViewController = LoginViewController()
            UIView.transition(from: window.rootViewController!.view,
                              to: self.loginViewController!.view,
                duration: 0.3,
                options: UIViewAnimationOptions(rawValue: 0),
                completion: nil)
            window.rootViewController = self.loginViewController
        }
    }
    
    func transitionToMasterViewController(_ session:SPTSession?) {
        if let window = self.window {
            masterViewController = MasterViewController()
            masterViewController!.session = session
            UIView.transition(from: window.rootViewController!.view,
                              to: self.masterViewController!.view,
                duration: 0.3,
                options: UIViewAnimationOptions(rawValue: 0),
                completion: nil)
            window.rootViewController = masterViewController!
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

