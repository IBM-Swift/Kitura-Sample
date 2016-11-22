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
import Foundation

class KituraSampleTests: XCTestCase {

    static var allTests: [(String, (KituraSampleTests) -> () throws -> Void)] {
        return [
            ("testURLParameters", testURLParameters),
            ("testMultiplicity", testMulitplicity),
            ("testCustomMiddlewareURLParameter", testCustomMiddlewareURLParameter),
            ("testCustomMiddlewareURLParameterWithQueryParam",
             testCustomMiddlewareURLParameterWithQueryParam),
            ("testGetHello", testGetHello),
            ("testGetError", testGetError),
            ("testMulti", testMulti),
            ("testParameter", testParameter),
            ("testStencil", testStencil),
            //TODO: enable the test on Linux
            // ("testMustache", testMustache),
            ("testStaticHTML", testStaticHTML),
            ("testStaticHTMLWithoutExtension", testStaticHTMLWithoutExtension),
            ("testStaticHTMLWithDifferentExtension", testStaticHTMLWithDifferentExtension),
            ("testRedirection", testRedirection)
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

    private typealias BodyChecker =  (String) -> Void
    private func runGetResponseTest(path: String, expectedResponseText: String? = nil,
                                    expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK,
                                    bodyChecker: BodyChecker? = nil) {
        performServerTest { expectation in
            self.performRequest("get", path: path, expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, expectedStatusCode,
                               "No success status code returned")
                if let optionalBody = try? response.readString(), let body = optionalBody {
                    if let expectedResponseText = expectedResponseText {
                        XCTAssertEqual(body, expectedResponseText, "mismatch in body")
                    }
                    bodyChecker?(body)
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

    private func runTestParameter(user: String) {
        let responseText = "<!DOCTYPE html><html><body><b>User:</b> \(user)</body></html>\n\n"
        runGetResponseTest(path: "/users/\(user)", expectedResponseText: responseText)
    }

    func testParameter() {
        runTestParameter(user: "John")
    }

    private func runTestUnknownPath(path: String) {
        runGetResponseTest(path: path,
                           expectedResponseText: "Route not found in Sample application!",
                           expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testUnknownPath() {
        runTestUnknownPath(path: "aaa")
    }

    func testStencil() {
        let expectedResponseText = "\n\nThere are 2 articles.\n\n\n" +
            "  - Migrating from OCUnit to XCTest by Kyle Fuller.\n\n" +
            "  - Memory Management with ARC by Kyle Fuller.\n\n"

        runGetResponseTest(path: "/articles", expectedResponseText: expectedResponseText)
    }

    func testMustache() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let arrivalDate = formatter.string(from: Date())
        let postponementDate = formatter.string(from: Date().addingTimeInterval(60*60*24*3))

        let expectedResponseText = "\n\nHello Arthur\n" +
            "Your beard trimmer will arrive on \(arrivalDate).\n\n" +
            "Well, on \(postponementDate) because of a Martian attack.\n\n"
        runGetResponseTest(path: "/trimmer", expectedResponseText: expectedResponseText)
    }

    func testStaticHTML() {
        let expectedResponseText = "<!DOCTYPE html>\n<html>\n<body>\n\n" +
                                   "<h1>Hello from Kitura </h1>\n\n" +
                                   "</body>\n</html>\n\n"
        runGetResponseTest(path: "/static/test.html", expectedResponseText: expectedResponseText)
    }

    func testStaticHTMLWithoutExtension() {
        runTestUnknownPath(path: "/static/test")
    }

    func testStaticHTMLWithDifferentExtension() {
        runTestUnknownPath(path: "/static/test.htm")
    }

    private func runTestThatCorrectHTMLTitleIsReturned(expectedTitle: String, path: String) {
        let pattern = "<title>(.*?)</title>"

        runGetResponseTest(path: path) { body in
            do {
                #if os(Linux)
                    let regularExpressionOptional: RegularExpression? =
                        try RegularExpression(pattern: pattern, options: [])
                #else
                    let regularExpressionOptional: NSRegularExpression? =
                        try NSRegularExpression(pattern: pattern, options: [])
                #endif
                guard let regularExpression = regularExpressionOptional else {
                    XCTFail("failed to create regular expression")
                    return
                }

                let matches = regularExpression.matches(in: body, options: [],
                    range: NSMakeRange(0, body.characters.count))

                guard let match = matches.first else {
                    XCTFail("no match of title tag in body")
                    return
                }

                #if os(Linux)
                    let titleRange = match.range(at: 1)
                #else
                    let titleRange = match.rangeAt(1)
                #endif

                let titleInBody = NSString(string: body).substring(with: titleRange)
                XCTAssertEqual(titleInBody, expectedTitle,
                               "returned title does not match the expected one")
            } catch {
                XCTFail("failed to create regular expression: \(error)")
            }
        }
    }

    func testRedirection() {
        runTestThatCorrectHTMLTitleIsReturned(expectedTitle: "IBM - United States", path: "/redir")
    }
}
