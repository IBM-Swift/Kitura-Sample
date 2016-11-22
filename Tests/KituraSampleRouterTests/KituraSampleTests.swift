/**
 * Copyright IBM Corporation 2016
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

class KituraSampleTests: XCTestCase {

    static var allTests: [(String, (KituraSampleTests) -> () throws -> Void)] {
        return [
            ("testURLParameters", testURLParameters),
            ("testMultiplicity", testMulitplicity),
            ("testCustomMiddlewareURLParameter", testCustomMiddlewareURLParameter),
            ("testCustomMiddlewareURLParameterWithQueryParam",
             testCustomMiddlewareURLParameterWithQueryParam)
        ]
    }

    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }

    func testURLParameters() {
        performServerTest { expectation in
            self.performRequest("get", path: "/users/:user", expectation: expectation) { response in
                expectation.fulfill()
            }
        }
    }

    func testMulitplicity() {
        performServerTest { expectation in
            self.performRequest("get", path: "/multi", expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "Route did not match")
                expectation.fulfill()
            }
        }
    }

    private func runGetResponseTest(path: String, expectedResponseText: String,
                                    expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK) {
        performServerTest { expectation in
            self.performRequest("get", path: path, expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, expectedStatusCode,
                               "No success status code returned")
                if let body = try? response.readString() {
                    XCTAssertEqual(body, expectedResponseText, "mismatch in body")
                } else {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            }
        }
    }

    func testCustomMiddlewareURLParameter() {
        runGetResponseTest(path: "/user/my_custom_id",
                           expectedResponseText: "my_custom_id|my_custom_id|")
    }

    func testCustomMiddlewareURLParameterWithQueryParam() {
        runGetResponseTest(path: "/user/my_custom_id?some_param=value",
                           expectedResponseText: "my_custom_id|my_custom_id|")
    }

    func testGetHello() {
        runGetResponseTest(path: "/hello", expectedResponseText: "Hello World, from Kitura!")
    }
}
