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

import SwiftJWT
import KituraContracts
import Foundation
import FileKit
import Kitura
import LoggerAPI

func initializeJWTRoutes(app: App) {
    
    // Create the JWT Coders
   do {
        let jwtEncoder = try App.generateJWTEncoder()
        let jwtDecoder = try App.generateJWTDecoder()
        // Set the JWT Coders on the route
        app.router.encoders[MediaType(type: .application, subType: "jwt")] = { return jwtEncoder }
        app.router.decoders[MediaType(type: .application, subType: "jwt")] = { return jwtDecoder }
    } catch {
        Log.error("failed to generate JWT coders: \(error)")
        return
    }

    // Register the app routes
	app.router.post("/jwt/create_token", handler: app.createToken)
    app.router.get("/jwt/protected", handler: app.protectedHandler)
    app.router.post("/refreshJWT", handler: app.jwtCoder)
}

extension App {
    
    // Generate a JWTEncoder that will sign the JWT using either the "rsa_private_key" or the "cert_private_key"
    // depending on the 'kid' (Key id) header of the JWT.
    static func generateJWTEncoder() throws -> JWTEncoder {
        // Retrieve the encrption Keys
        let localURL = FileKit.projectFolderURL
        
        let rsaPrivateKey = try Data(contentsOf: localURL.appendingPathComponent("/JWT/rsa_private_key", isDirectory: false))
        let certPrivateKey = try Data(contentsOf: localURL.appendingPathComponent("/JWT/cert_private_key", isDirectory: false))
        let jwtSigners: [String: JWTSigner] = ["0": .rs256(privateKey: rsaPrivateKey), "1": .rs256(privateKey: certPrivateKey)]
        return JWTEncoder(keyIDToSigner: { kid in return jwtSigners[kid]})
    }
    
    // Generate a JWTDecoder that will verify the JWT using either the "rsa_public_key" or the "certificate"
    // depending on the 'kid' (Key id) header of the JWT.
    static func generateJWTDecoder() throws -> JWTDecoder {
        // Retrieve the encrption Keys
        let localURL = FileKit.projectFolderURL
        
        let rsaPublicKey = try Data(contentsOf: localURL.appendingPathComponent("/JWT/rsa_public_key", isDirectory: false))
        let certificate = try Data(contentsOf: localURL.appendingPathComponent("/JWT/certificate", isDirectory: false))
        let jwtVerifiers: [String: JWTVerifier] = ["0": .rs256(publicKey: rsaPublicKey), "1": .rs256(certificate: certificate)]
        return JWTDecoder(keyIDToVerifier: { kid in return jwtVerifiers[kid]})
    }
    
    // Create a JWT token and return it to the user.
    func createToken(claims: TokenDetails, respondWith: (JWT<TokenDetails>?, RequestError?) -> Void) {
        let datedClaim = TokenDetails(sub: claims.sub,
                                      iat: Date(),
                                      exp: Date(timeIntervalSinceNow: 300),
                                      kid: claims.kid,
                                      favourite: claims.favourite)
        let jwt = JWT(header: Header(kid: claims.kid), claims: datedClaim)
        respondWith(jwt, nil)
    }
    
    // A route that requires a valid JWT to be accessed
    func protectedHandler(typeSafeJWT: TypeSafeJWT<TokenDetails>, respondWith: (JWT<TokenDetails>?, RequestError?) -> Void) {
        guard case .success = typeSafeJWT.jwt.validateClaims() else {
            return respondWith(nil, .badRequest)
        }
        respondWith(typeSafeJWT.jwt, nil)
    }
    
    // A route the refreshed the date claims on the provided JWT and returns it to the user.
    func jwtCoder(inJWT: JWT<TokenDetails>, respondwith: (JWT<TokenDetails>?, RequestError?) -> Void ) {
        var refreshedJWT = inJWT
        refreshedJWT.claims = TokenDetails(sub: inJWT.claims.sub,
                                      iat: Date(),
                                      exp: Date(timeIntervalSinceNow: 300),
                                      kid: inJWT.claims.kid,
                                      favourite: inJWT.claims.favourite)
        respondwith(refreshedJWT, nil)
    }
}

struct TokenDetails: Codable, QueryParams, Claims {
    // Standard JWT Fields
    let sub: String
    var iat: Date?
    var exp: Date?
    let kid: String
    
    // Custom JTW fields
    let favourite: Int
}

struct TypeSafeJWT<C: Claims>: TypeSafeMiddleware {
    let jwt: JWT<C>
    
    public static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (TypeSafeJWT<C>?, RequestError?) -> Void) {
        guard let decoder = try? App.generateJWTDecoder() else {
            return completion(nil, .internalServerError)
        }
        let authorizationHeader = request.headers["Authorization"]
        guard let authorizationHeaderComponents = authorizationHeader?.components(separatedBy: " "),
            authorizationHeaderComponents.count == 2,
            authorizationHeaderComponents[0] == "Bearer",
            let jwt = try? decoder.decode(JWT<C>.self, fromString: authorizationHeaderComponents[1])
        else {
            return completion(nil, .unauthorized)
        }
        completion(TypeSafeJWT(jwt: jwt), nil)
    }
}
