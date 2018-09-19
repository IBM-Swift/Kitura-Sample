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

import XCTest
import KituraNet
import Foundation
@testable import Application
@testable import CredentialsFacebook
@testable import CredentialsGoogle

class TestTokenAuthRoutes: KituraTest {
    
    static var allTests: [(String, (TestTokenAuthRoutes) -> () throws -> Void)] {
        return [
            ("testTypeSafeGoogleToken", testTypeSafeGoogleToken),
            ("testTypeSafeFacebookToken", testTypeSafeFacebookToken),
            ("testTypeSafeMultiToken", testTypeSafeMultiToken),
        ]
    }
    let googleProfile = GoogleTokenProfile(id: "123", name: "John Doe", family_name: "Doe", given_name: "John", picture: "www.urlToPicture.com", locale: "en", gender: nil, email: nil, verified_email: false)
    
    let facebookProfile = FacebookTokenProfile(id: "456", name: "Jane Doe", picture: FacebookPicture(data: .init(url: "www.urlToPicture.com", height: 10, width: 10)), first_name: "Jane", last_name: "Doe", name_format: "{first}{last}", short_name: "Jane Doe", middle_name: nil, email: nil, age_range: nil, birthday: nil, friends: nil, gender: nil, hometown: nil, likes: nil, link: nil, location: nil, photos: nil, posts: nil, tagged_places: nil)
    
    func testTypeSafeGoogleToken() {
        guard let app = try? App() else {
            return XCTFail("failed to initialize application")
        }

        app.tsGoogleHandler(user: googleProfile) { (response, error) in
            if error != nil {
                return XCTFail("error sent from handler")
            }
            guard let response = response else {
                return XCTFail("no reponse from handler")
            }
            XCTAssertEqual(googleProfile, response, "response profile did not match input profile")
        }
    }
    
    func testTypeSafeFacebookToken() {
        guard let app = try? App() else {
            return XCTFail("failed to initialize application")
        }

        app.tsFacebookHandler(user: facebookProfile) { (response, error) in
            if error != nil {
                return XCTFail("error sent from handler")
            }
            guard let response = response else {
                return XCTFail("no reponse from handler")
            }
            XCTAssertEqual(facebookProfile, response, "response profile did not match input profile")
        }
    }
    
    func testTypeSafeMultiToken() {
        guard let app = try? App() else {
            return XCTFail("failed to initialize application")
        }
        let multiGoogleProfile = MultiTokenAuth(successfulAuth: googleProfile)
        
        app.tsMultiHandler(user: multiGoogleProfile) { (response, error) in
            if error != nil {
                return XCTFail("error sent from handler")
            }
            guard let response = response else {
                return XCTFail("no reponse from handler")
            }
            XCTAssertEqual(multiGoogleProfile, response, "response profile did not match input profile")
        }
        
        let multiFacebookProfile = MultiTokenAuth(successfulAuth: facebookProfile)

        app.tsMultiHandler(user: multiFacebookProfile) { (response, error) in
            if error != nil {
                return XCTFail("error sent from handler")
            }
            guard let response = response else {
                return XCTFail("no reponse from handler")
            }
            XCTAssertEqual(multiFacebookProfile, response, "response profile did not match input profile")
        }
    }
}

extension GoogleTokenProfile: Equatable {
    public static func == (lhs: GoogleTokenProfile, rhs: GoogleTokenProfile) -> Bool {
        return lhs.email == rhs.email &&
        lhs.family_name == rhs.family_name &&
        lhs.gender == rhs.gender &&
        lhs.given_name == rhs.given_name &&
        lhs.id == rhs.id &&
        lhs.locale == rhs.locale &&
        lhs.name == rhs.name &&
        lhs.picture == rhs.picture &&
        lhs.verified_email == rhs.verified_email &&
        lhs.provider == rhs.provider
    }
}

extension FacebookTokenProfile: Equatable {
    public static func == (lhs: FacebookTokenProfile, rhs: FacebookTokenProfile) -> Bool {
        return lhs.id == rhs.id &&
        lhs.gender == rhs.gender &&
        lhs.first_name == rhs.first_name &&
        lhs.name == rhs.name &&
        lhs.last_name == rhs.last_name &&
        lhs.name_format == rhs.name_format &&
        lhs.provider == rhs.provider
    }
}

extension MultiTokenAuth: Equatable {
    public static func == (lhs: MultiTokenAuth, rhs: MultiTokenAuth) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.provider == rhs.provider
    }
}
