//
//  SpotifySession.swift
//  Longplay
//
//  Created by Joe Nguyen on 14/08/2015.
//  Copyright (c) 2015 onyenjug. All rights reserved.
//

class SpotifySession {
    
    let dataStore = DataStore()
    var session: SPTSession?
    
    func setup(completed:((session:SPTSession?,
        didLogin:Bool) -> ())) {
            
            SPTAuth.defaultInstance().clientID = "d1ee9fb41d4245fe8f7ec6a5a7298c75"
            SPTAuth.defaultInstance().redirectURL = NSURL(string: "longplay-app://login-callback")
            SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope,SPTAuthUserLibraryReadScope,SPTAuthUserLibraryModifyScope]
            SPTAuth.defaultInstance().tokenSwapURL = NSURL(string: "https://blooming-hollows-5367.herokuapp.com/swap")
            SPTAuth.defaultInstance().tokenRefreshURL = NSURL(string: "https://blooming-hollows-5367.herokuapp.com/refresh")
            
            let dataStore = DataStore()
            if let sessionValues = dataStore.spotifySessionValues {
                if let
                    username = sessionValues["username"] as? String,
                    accessToken = sessionValues["accessToken"] as? String,
                    encryptedRefreshToken = sessionValues["encryptedRefreshToken"] as? String,
                    expirationDate = sessionValues["expirationDate"] as? NSDate {
                        let session = SPTSession(userName: username,
                            accessToken: accessToken,
                            encryptedRefreshToken:encryptedRefreshToken,
                            expirationDate: expirationDate)
                        if session.isValid() {
                            NSLog("Session valid")
                            completed(session:session, didLogin: true)
                        } else {
                            NSLog("expirationDate: %@", expirationDate)
                            NSLog("Session invalid, renewing")
                            SPTAuth.defaultInstance().renewSession(session,
                                callback: {
                                    (error:NSError!, session:SPTSession!) -> Void in
                                    self.session = session
                                    if session != nil {
                                        self.persistSpotifySessionValues(session)
                                    }
                                    if error != nil {
                                        NSLog("error: %@", error)
                                        completed(session:session, didLogin: false)
                                    } else if session == nil {
                                        NSLog("session is nil")
                                        completed(session:session, didLogin: false)
                                    } else {
                                        completed(session:session, didLogin: true)
                                    }
                            })
                        }
                }
            } else {
                NSLog("spotifySessionValues not found")
                completed(session:session, didLogin: false)
            }
    }
    
    func persistSpotifySessionValues(session:SPTSession) {
        
        var sessionValues = ["username": session.canonicalUsername,
            "accessToken": session.accessToken,
            "expirationDate": session.expirationDate]
        if let encryptedRefreshToken = session.encryptedRefreshToken {
            sessionValues["encryptedRefreshToken"] = encryptedRefreshToken
        }
        dataStore.spotifySessionValues = sessionValues
    }
    
    func handleAuthCallback(session:SPTSession?,
        error:NSError?,
        completed:((session:SPTSession?)->())?) {
            if error != nil {
                // TODO: handle error
                NSLog("error: %@", error!)
            }
            self.session = session
            if let session = session {
                self.persistSpotifySessionValues(session)
            }
            if let completed = completed {
                completed(session:session)
            }
    }
}
