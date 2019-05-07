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

import Credentials
import CredentialsFacebook
import CredentialsGoogle
import KituraSession
// IBMCloudAppID requires OpenSSL that is not included on Mac by default.
// To use this on mac, install OpenSSL:
// `$ brew install openssl`
// then remove all the `#if os(Linux)` tags for AppID in Kitura sample.
#if os(Linux) && swift(>=4.2)
import IBMCloudAppID
#endif

func initializeOauth2Routes(app: App) {
    
    // Replace these values for your application from https://developers.facebook.com/apps/
    let fbClientId = "<your Facebook app ID>"
    let fbClientSecret = "<your Facebook app secret>"
    
    // Replace these values for your application.
    // To set up an application follow these instructions: https://support.google.com/cloud/answer/6158849?hl=en
    let googleClientId = "<your Google app ID>"
    let googleClientSecret = "<your Google app secret>"
    
#if os(Linux) && swift(>=4.2)
    // replace these values with those from your APP-ID application: https://console.bluemix.net/docs/services/appid/index.html
    let appIdOptions = [
        "clientId": "<your appid clientID>",
        "secret": "<your appid secret>",
        "tenantId": "<your appid tenantId>",
        "oauthServerUrl": "<your appid oauthServerUrl>",
        "redirectUri": app.cloudEnv.url + "/oauth2/appid/callback"
    ]
#endif
    
    // Session is required to keep the user logged in after authentication
    // If a user is logged in with a redirecting authentication, all routes with this session will have a userProfile
    let session = Session(secret: "AuthSecret", cookie: [CookieParameter.name("Kitura-Auth-cookie")])
    app.router.all("/oauth2", middleware: session)

    
    // Facebook Oauth Setup
    let oauthFBCredentials = Credentials()

    // Your app callback route which has credentials registered on it
    // This must be added to your Facebook app authorized Callbacks
    let fbCallbackUrl = app.cloudEnv.url + "/oauth2/facebook/callback"

    let fbCredentials = CredentialsFacebook(clientId: fbClientId, clientSecret: fbClientSecret, callbackUrl: fbCallbackUrl, options: ["scope":"email", "fields": "id,first_name,last_name,name,picture,email"])
    oauthFBCredentials.options["failureRedirect"] = "/oauth2.html"
    oauthFBCredentials.options["successRedirect"] = "/facebookloggedin.html"

    oauthFBCredentials.register(plugin: fbCredentials)
    // Login route
    app.router.get("/oauth2/facebook", handler: oauthFBCredentials.authenticate(credentialsType: fbCredentials.name))
    // App callback route
    app.router.get("/oauth2/facebook/callback", handler: oauthFBCredentials.authenticate(credentialsType: fbCredentials.name))
    
    // Google Oauth Setup
    let oauthGoogleCredentials = Credentials()
    
    // Your app callback route which has credentials registered on it.
    // This must be added to your Google app authorized Callbacks
    let googleCallbackUrl = app.cloudEnv.url + "/oauth2/google/callback"
    
    let googleCredentials = CredentialsGoogle(clientId: googleClientId, clientSecret: googleClientSecret, callbackUrl: googleCallbackUrl)
    oauthGoogleCredentials.options["failureRedirect"] = "/oauth2.html"
    oauthGoogleCredentials.options["successRedirect"] = "/googleloggedin.html"
    
    oauthGoogleCredentials.register(plugin: googleCredentials)
    // Login route
    app.router.get("/oauth2/google", handler: oauthGoogleCredentials.authenticate(credentialsType: googleCredentials.name))
    // App callback route
    app.router.get("/oauth2/google/callback", handler: oauthGoogleCredentials.authenticate(credentialsType: googleCredentials.name))
    
// IBMCloudAppID requires OpenSSL that is not included on Mac by default.
#if os(Linux) && swift(>=4.2)
    // AppID Oauth Setup
    let kituraCredentials = Credentials()
    
    if #available(OSX 10.12, *) {
        let webappKituraCredentialsPlugin = WebAppKituraCredentialsPlugin(options: appIdOptions)
        kituraCredentials.register(plugin: webappKituraCredentialsPlugin)
        app.router.get("/oauth2/appid",
                       handler: kituraCredentials.authenticate(credentialsType: webappKituraCredentialsPlugin.name,
                                                               successRedirect: "/appidloggedin.html",
                                                               failureRedirect: "/oauth2.html"
        ))
        // Callback to finish the authorization process. Will retrieve access and identity tokens from App ID
        app.router.get("/oauth2/appid/callback",
                       handler: kituraCredentials.authenticate(credentialsType: webappKituraCredentialsPlugin.name,
                                                               successRedirect: "/appidloggedin.html",
                                                               failureRedirect: "/oauth2.html"
        ))
    }
#endif
    
    // Route which only allows access if the user has authenticated with either AppID, Facebook or Google
    app.router.get("/oauth2/protected") { request, response, next in
        // check user profile for successful login
        guard let user = request.userProfile else {
            return try response.send("Not authorized to view this route").end()
        }
        try response.send("Hello \(user.displayName)").end()
    }
    
    // Route to log out from either either AppID, Facebook or Google.
    app.router.get("/oauth2/logout") { request, response, next in
        // check user profile for successful login
        guard let user = request.userProfile else {
            return try response.send("You are not currently logged in").end()
        }
        // This will log the user out regardless of whether they logged in with Facebook or Google.
        oauthGoogleCredentials.logOut(request: request)
        return try response.send("User: \(user.displayName) successfully logged out").end()
    }
}
