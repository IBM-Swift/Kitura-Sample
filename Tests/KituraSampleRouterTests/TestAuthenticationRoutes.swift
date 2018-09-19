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

class TestAuthenticationRoutes: KituraTest {
    
    static var allTests: [(String, (TestAuthenticationRoutes) -> () throws -> Void)] {
        return [
            ("testTypeSafeFailedAuthentication", testTypeSafeFailedAuthentication),
            ("testTypeSafeAuthentication", testTypeSafeAuthentication),
            ("testRawFailedAuthentication", testRawFailedAuthentication),
            ("testRawAuthentication", testRawAuthentication),
        ]
    }
    
    func testTypeSafeFailedAuthentication() {
        performServerTest { expectation in
            self.performRequest("get", path: "/basic", expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, HTTPStatusCode.unauthorized, "unauthorized not sent when no header")
                expectation.fulfill()
            }
        }
    }
    
    func testTypeSafeAuthentication() {
        let authResponse = AuthID(id: "username")
        guard let authenticationString = "username:password".data(using: .utf8)?.base64EncodedString() else {
            return XCTFail("failed to encode auth string")
        }
        performServerTest { expectation in
            self.performRequest("get", path: "/basic", expectation: expectation, headers: ["Authorization": "Basic \(authenticationString)"]) { response in
                self.checkCodableResponse(response: response, expectedResponse: authResponse)
                expectation.fulfill()
            }
        }
    }
    
    func testRawFailedAuthentication() {
        performServerTest { expectation in
            self.performRequest("get", path: "/rawbasic", expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, HTTPStatusCode.unauthorized, "unauthorized not sent when no header")
                expectation.fulfill()
            }
        }
    }
    
    func testRawAuthentication() {
        let authResponse = AuthID(id: "username")
        guard let authenticationString = "username:password".data(using: .utf8)?.base64EncodedString() else {
            return XCTFail("failed to encode auth string")
        }
        performServerTest { expectation in
            self.performRequest("get", path: "/rawbasic", expectation: expectation, headers: ["Authorization": "Basic \(authenticationString)"]) { response in
                self.checkCodableResponse(response: response, expectedResponse: authResponse)
                expectation.fulfill()
            }
        }
    }
}

struct AuthID: Codable, Equatable {
    
    let id: String
    
    static func == (lhs: AuthID, rhs: AuthID) -> Bool {
        return lhs.id == rhs.id
    }
}
