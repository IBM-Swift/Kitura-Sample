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
        let id = "my_custom_id"
        runGetResponseTest(path: "/user/\(id)",
                           expectedResponseText: "\(id)|\(id)|")
    }

    func testCustomMiddlewareURLParameterWithQueryParam() {
        let id = "my_custom_id"
        runGetResponseTest(path: "/user/\(id)?some_param=value",
                           expectedResponseText: "\(id)|\(id)|")
    }

    func testGetHello() {
        runGetResponseTest(path: "/hello", expectedResponseText: "Hello World, from Kitura!")
    }

    func testGetError() {
        runGetResponseTest(path: "/error",
                           expectedResponseText: "Caught the error: Example of error being set",
                           expectedStatusCode: HTTPStatusCode.internalServerError)
    }

    func testMulti() {
        runGetResponseTest(path: "/multi",
                           expectedResponseText: "I'm here!\nMe too!\nI come afterward..\n")
    }

    func testParameter() {
        let user = "John"
        let responseText = "<!DOCTYPE html><html><body><b>User:</b> \(user)</body></html>\n\n"
        runGetResponseTest(path: "/users/\(user)", expectedResponseText: responseText)
    }

    func testUnknownRoute() {
        runGetResponseTest(path: "/aaa",
                           expectedResponseText: "Route not found in Sample application!",
                           expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testStencil() {
        let expectedResponseText = "\n\nThere are 2 articles.\n\n\n" +
            "  - Migrating from OCUnit to XCTest by Kyle Fuller.\n\n" +
            "  - Memory Management with ARC by Kyle Fuller.\n\n"

        runGetResponseTest(path: "/articles", expectedResponseText: expectedResponseText)
    }

    func testMustache() {
        let expectedResponseText = "\n\nHello Arthur\n" +
                                   "Your beard trimmer will arrive on Nov 22, 2016.\n\n" +
                                   "Well, on Nov 25, 2016 because of a Martian attack.\n\n"
        runGetResponseTest(path: "/trimmer", expectedResponseText: expectedResponseText)
    }
}
