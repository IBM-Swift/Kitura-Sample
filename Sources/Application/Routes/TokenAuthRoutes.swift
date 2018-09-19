/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import KituraSession
import Credentials
import CredentialsGoogle
import CredentialsFacebook
import KituraContracts
import Kitura
import LoggerAPI

func initializeTokenAuthRoutes(app: App) {
    
    // Codable Google token authentication.
    app.router.get("/typesafegoogletoken", handler: app.tsGoogleHandler)
    
    // Set this as your app id to only authenticate tokens from your application.
    FacebookTokenProfile.appID = nil
        
    // Codable Google token authentication.
    app.router.get("/typesafefacebooktoken", handler: app.tsFacebookHandler)
    
    // Codable token authentication which accepts Google and Facebook tokens.
    app.router.get("/typesafemultitoken", handler: app.tsMultiHandler)
    
    // Oauth tokens in raw routes
    
    // Initialize credentials
    let tokenCredentials = Credentials()
    
    // Initialize and register acceptable token authentication
    tokenCredentials.register(plugin: CredentialsFacebookToken())
    tokenCredentials.register(plugin: CredentialsGoogleToken())
    app.router.get("/rawtokenauth", middleware: tokenCredentials)
    app.router.get("/rawtokenauth", handler: app.rawHandler)
}

extension App {
    // Oauth token handlers in Codable routes
    
    func tsGoogleHandler(user: GoogleTokenProfile, respondWith: (GoogleTokenProfile?, RequestError?) -> Void) {
        Log.verbose("User \(user.name) authenticated with type-safe Google token authentication")
        respondWith(user, nil)
    }
    
    func tsFacebookHandler(user: FacebookTokenProfile, respondWith: (FacebookTokenProfile?, RequestError?) -> Void) {
        Log.verbose("User \(user.name) with id \(user.id) authenticated with type-safe Facebook token authentication")
        respondWith(user, nil)
    }
    
    func tsMultiHandler(user: MultiTokenAuth, respondWith: (MultiTokenAuth?, RequestError?) -> Void) {
        Log.verbose("User \(user.name) with id \(user.id) authenticated with type-safe multi token authentication")
        respondWith(user, nil)
    }
    
    // Oauth token handlers in raw routes
    func rawHandler(request: RouterRequest, response: RouterResponse, next: () -> Void) throws -> Void {
            // If there is no userProfile they failed authentication
            guard let userProfile = request.userProfile else {
                Log.verbose("Failed raw token authentication")
                response.status(.unauthorized)
                try response.end()
                return
            }
            Log.verbose("User \(userProfile.displayName) with id \(userProfile.id) authenticated with Raw token authentication")
            response.send("Hello \(userProfile.displayName)")
    }
}
