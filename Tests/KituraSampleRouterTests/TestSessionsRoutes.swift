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
import KituraSession

class TestSessionsRoutes: KituraTest {
    
    static var allTests: [(String, (TestSessionsRoutes) -> () throws -> Void)] {
        return [
            ("testGetTypeSafeSession", testGetTypeSafeSession),
            ("testPostTypeSafeSession", testPostTypeSafeSession),
            ("testTypeSafeSessionPersistence", testTypeSafeSessionPersistence),
            ("testGetRawSession", testGetRawSession),
            ("testPostRawSession", testPostRawSession),
            ("testRawSessionPersistence", testRawSessionPersistence),
        ]
    }
    
    func testGetTypeSafeSession() {
        let emptyBooks: [Book] = []
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("get", path: "/session", expectation: expectation, callback: { response in
                self.checkCodableResponse(response: response, expectedResponseArray: emptyBooks)
                expectation.fulfill()
            })
        })
    }
    
    func testPostTypeSafeSession() {
        let jsonBook: String = "{\"name\": \"bookName\",\"author\": \"bookAuthor\",\"rating\": 4}"
        let objectBook = Book(name: "bookName", author: "bookAuthor", rating: 4)
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("post", path: "/session", body: jsonBook, expectation: expectation, headers: ["Content-Type": "application/json"], callback: { response in
                self.checkCodableResponse(response: response, expectedResponse: objectBook, expectedStatusCode: HTTPStatusCode.created)
                expectation.fulfill()
            })
        })
    }
    
    func testTypeSafeSessionPersistence() {
        let jsonBook: String = "{\"name\": \"bookName\",\"author\": \"bookAuthor\",\"rating\": 4}"
        let objectBook = Book(name: "bookName", author: "bookAuthor", rating: 4)
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("post", path: "/session", body: jsonBook, expectation: expectation, headers: ["Content-Type": "application/json"], callback: { response in
                self.checkCodableResponse(response: response, expectedResponse: objectBook, expectedStatusCode: HTTPStatusCode.created)
                guard let cookie = response.headers["Set-cookie"] else {
                    XCTFail("no set cookie recieved")
                    return
                }
                self.performRequest("get", path: "/session", expectation: expectation, headers: ["cookie": cookie[0], "Content-Type": "application/json"], callback: { response in
                    self.checkCodableResponse(response: response, expectedResponseArray: [objectBook])
                    expectation.fulfill()
                })
            })
        })
    }
    func testGetRawSession() {
        let emptyBooks: [Book] = []
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("get", path: "/rawsession", expectation: expectation, callback: { response in
                self.checkCodableResponse(response: response, expectedResponseArray: emptyBooks)
                expectation.fulfill()
            })
        })
    }
    
    func testPostRawSession() {
        let jsonBook: String = "{\"name\": \"bookName\",\"author\": \"bookAuthor\",\"rating\": 4}"
        let objectBook = Book(name: "bookName", author: "bookAuthor", rating: 4)
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("post", path: "/rawsession", body: jsonBook, expectation: expectation, headers: ["Content-Type": "application/json"], callback: { response in
                self.checkCodableResponse(response: response, expectedResponse: objectBook, expectedStatusCode: HTTPStatusCode.created)
                expectation.fulfill()
            })
        })
    }
    
    func testRawSessionPersistence() {
        let jsonBook: String = "{\"name\": \"bookName\",\"author\": \"bookAuthor\",\"rating\": 4}"
        let objectBook = Book(name: "bookName", author: "bookAuthor", rating: 4)
        performServerTest(asyncTasks: { expectation in
            // Login to create the session and set session.sessionTestKey to be sessionTestValue
            self.performRequest("post", path: "/rawsession", body: jsonBook, expectation: expectation, headers: ["Content-Type": "application/json"], callback: { response in
                self.checkCodableResponse(response: response, expectedResponse: objectBook, expectedStatusCode: HTTPStatusCode.created)
                guard let cookie = response.headers["Set-cookie"] else {
                    XCTFail("no set cookie recieved")
                    return
                }
                self.performRequest("get", path: "/rawsession", expectation: expectation, headers: ["cookie": cookie[0], "Content-Type": "application/json"], callback: { response in
                    self.checkCodableResponse(response: response, expectedResponseArray: [objectBook])
                    expectation.fulfill()
                })
            })
        })
    }
}
