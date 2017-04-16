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
    
    func setup(_ completed:@escaping ((_ session:SPTSession?,
        _ didLogin:Bool) -> ())) {
        
        SPTAuth.defaultInstance().clientID = "d1ee9fb41d4245fe8f7ec6a5a7298c75"
        SPTAuth.defaultInstance().redirectURL = URL(string: "longplay-app://login-callback")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope,SPTAuthUserLibraryReadScope,SPTAuthUserLibraryModifyScope]
        SPTAuth.defaultInstance().tokenSwapURL = URL(string: "https://blooming-hollows-5367.herokuapp.com/swap")
        SPTAuth.defaultInstance().tokenRefreshURL = URL(string: "https://blooming-hollows-5367.herokuapp.com/refresh")
        
        let dataStore = DataStore()
        if let sessionValues = dataStore.spotifySessionValues {
            if let
                username = sessionValues["username"] as? String,
                let accessToken = sessionValues["accessToken"] as? String,
                let encryptedRefreshToken = sessionValues["encryptedRefreshToken"] as? String,
                let expirationDate = sessionValues["expirationDate"] as? Date {
                let session = SPTSession(userName: username,
                                         accessToken: accessToken,
                                         encryptedRefreshToken:encryptedRefreshToken,
                                         expirationDate: expirationDate)
                if (session?.isValid())! {
                    NSLog("Session valid")
                    completed(session, true)
                } else {
                    print("expirationDate: %@", expirationDate)
                    NSLog("Session invalid, renewing")
                    SPTAuth.defaultInstance().renewSession(
                        session,
                        callback: { (error:Error?, session:SPTSession?) in
                            self.session = session
                            if let session = session {
                                self.persistSpotifySessionValues(session)
                            }
                            if let error = error {
                                print("error: %@", error)
                                completed(session, false)
                            } else if session == nil {
                                NSLog("session is nil")
                                completed(session, false)
                            } else {
                                completed(session, true)
                            }
                    })
                }
            }
        } else {
            NSLog("spotifySessionValues not found")
            completed(session, false)
        }
    }
    
    func persistSpotifySessionValues(_ session:SPTSession) {
        
        var sessionValues = ["username": session.canonicalUsername,
            "accessToken": session.accessToken,
            "expirationDate": session.expirationDate] as [String : Any]
        if let encryptedRefreshToken = session.encryptedRefreshToken {
            sessionValues["encryptedRefreshToken"] = encryptedRefreshToken
        }
        dataStore.spotifySessionValues = sessionValues as [String : AnyObject]?
    }
    
    func handleAuthCallback(_ session:SPTSession?,
        error:NSError?,
        completed:((_ session:SPTSession?)->())?) {
            if error != nil {
                // TODO: handle error
                NSLog("error: %@", error!)
            }
            self.session = session
            if let session = session {
                self.persistSpotifySessionValues(session)
            }
            if let completed = completed {
                completed(session)
            }
    }
}
