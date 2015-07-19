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
    
    var session: SPTSession?
    var loginViewController:LoginViewController?
    var masterViewController:MasterViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        if let window = self.window {
            setupSpotifySession({ (didLogin:Bool, session:SPTSession?) -> () in
                if !didLogin {
                    self.loginViewController = LoginViewController()
                    window.rootViewController = self.loginViewController
                    window.makeKeyAndVisible()
                } else {
                    self.transitionToMasterViewController(session)
                    window.makeKeyAndVisible()
                }
            })
        }
        
        application.statusBarHidden = true
        
        return true
    }
    
    func setupSpotifySession(callback:((didLogin:Bool, session:SPTSession?) -> ())) {
        if let sessionValues = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySessionValues") as? NSDictionary {
            if let
                username = sessionValues["username"] as? String,
                accessToken = sessionValues["accessToken"] as? String,
                expirationDate = sessionValues["expirationDate"] as? NSDate {
                    let session = SPTSession(userName: username, accessToken: accessToken, expirationDate: expirationDate)
                    if session.isValid() {
                        callback(didLogin: true, session:session)
                    } else {
                        SPTAuth.defaultInstance().renewSession(session,
                            callback: {
                                (error:NSError!, session:SPTSession!) -> Void in
                                if error != nil {
                                    NSLog("error: %@", error)
                                    callback(didLogin: false, session:session)
                                } else {
                                    callback(didLogin: true, session:session)
                                }
                                
                        })
                    }
            }
        } else {
            callback(didLogin: false, session:session)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if (SPTAuth.defaultInstance().canHandleURL(url)) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url,
                callback: { (error:NSError!, session:SPTSession!) -> Void in
                    self.handleAuthCallback(session, error: error)
            })
        }
        return false
    }
    
    func handleAuthCallback(session:SPTSession?, error:NSError?) {
        if error != nil {
            // TODO: handle error
        }
        self.session = session
        if let session = session {
            NSUserDefaults.standardUserDefaults().setObject(
                ["username": session.canonicalUsername,
                "accessToken": session.accessToken,
                "expirationDate": session.expirationDate],
                forKey: "SpotifySessionValues")
        }
        transitionToMasterViewController(session)
        if let loginViewController = loginViewController,
            masterViewController = masterViewController{
                UIView.transitionFromView(loginViewController.view,
                    toView: masterViewController.view,
                    duration: 0.5,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    completion: nil)
        }
    }
    
    func transitionToMasterViewController(session:SPTSession?) {
        if let window = self.window {
            masterViewController = MasterViewController()
            masterViewController!.session = session
            window.rootViewController = masterViewController!
        }
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


}

