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

class KituraSampleTests: KituraTest {

    static var allTests: [(String, (KituraSampleTests) -> () throws -> Void)] {
        return [
            ("testURLParameters", testURLParameters),
            ("testMultiplicity", testMulitplicity),
            ("testCustomMiddlewareURLParameter", testCustomMiddlewareURLParameter),
            ("testCustomMiddlewareURLParameterWithQueryParam",
             testCustomMiddlewareURLParameterWithQueryParam),
            ("testGetError", testGetError),
            ("testMulti", testMulti),
            ("testParameter", testParameter),
            ("testParameterWithWhiteSpace", testParameterWithWhiteSpace),
            ("testUnknownPath", testUnknownPath),
            ("testStencil", testStencil),
            ("testStencilWithHTMLExtension", testStencilWithHTMLExtension),
            ("testStencilIncludedDocument", testStencilIncludedDocument),
            ("testStencilInSubdirectory", testStencilInSubdirectory),
            ("testCustomTagStencil", testCustomTagStencil),
            ("testStaticHTML", testStaticHTML),
            ("testStaticHTMLWithoutExtension", testStaticHTMLWithoutExtension),
            ("testStaticHTMLWithDifferentExtension", testStaticHTMLWithDifferentExtension),
            ("testRedirection", testRedirection),
            ("testDefaultIndex", testDefaultIndex),
            ("testIndex", testIndex),
            ("testDefaultPage", testDefaultPage),
            ("testMarkdownRoute", testMarkdownRoute),
        ]
    }

    func testURLParameters() {
        performServerTest { expectation in
            self.performRequest("get", path: "/users/:user", expectation: expectation) { response in
                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "Route did not match")
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

    func testGetError() {
        runGetResponseTest(path: "/error",
                           expectedResponseText: "Caught the error: Example of error being set",
                           expectedStatusCode: HTTPStatusCode.OK)
    }

    func testMulti() {
        runGetResponseTest(path: "/multi",
                           expectedResponseText: "I'm here!\nMe too!\nI come afterward..\n")
    }
    
    func testMarkdownRoute() {
        let expectedStencilResponseText = """
        <h1>Sample documentation Table of Contents</h1>
        <ol>
        <li>
        <p><a href="/docs/doc1.md">First chapter</a></p>
        </li>
        <li>
        <p><a href="/docs/doc2.md">Second chapter</a></p>
        </li>
        </ol>\n
        """

        runGetResponseTest(path: "/docs",
                           expectedResponseText: expectedStencilResponseText)
        
        runGetResponseTest(path: "/docs/",
                           expectedResponseText: expectedStencilResponseText)

    }


    func testParameter() {
        runTestParameter(user: "John")
    }

    func testParameterWithWhiteSpace() {
        runTestParameter(user: "John Doe")
    }

    private func runTestUnknownPath(path: String) {
        runGetResponseTest(path: path,
                           expectedResponseText: "Route not found in Sample application!",
                           expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testUnknownPath() {
        runTestUnknownPath(path: "aaa")
    }

    let expectedStencilResponseText = "There are 2 articles.\n\n\n" +
                               "  - Migrating from OCUnit to XCTest by Kyle Fuller.\n\n" +
                               "  - Memory Management with ARC by Kyle Fuller.\n\n"

    func testStencil() {
        runGetResponseTest(path: "/articles", expectedResponseText: expectedStencilResponseText)
    }

    func testStencilWithHTMLExtension() {
        runGetResponseTest(path: "/articles.html",
            expectedResponseText: "<head></head><body>" + expectedStencilResponseText + "</body>\n")
    }

    func testStencilIncludedDocument() {
        runGetResponseTest(path: "/articles_include", expectedResponseText: expectedStencilResponseText)
    }

    func testStencilInSubdirectory() {
        runGetResponseTest(path: "/articles_subdirectory", expectedResponseText: expectedStencilResponseText)
    }

    func testCustomTagStencil() {
        runGetResponseTest(path: "/custom_tag_stencil", expectedResponseText: "\n\nHello World\n")
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

    func testRedirection() {
        runTestThatCorrectHTMLTitleIsReturned(expectedTitle: "Kitura - An Enterprise-Grade Server-Side Swift Web Framework", path: "/redirect")
    }

    func testDefaultIndex() {
        runTestThatCorrectHTMLTitleIsReturned(expectedTitle: "Index", path: "/static")
    }

    func testIndex() {
        runTestThatCorrectHTMLTitleIsReturned(expectedTitle: "Index", path: "/static/index.html")
    }

    func testDefaultPage() {
        runTestThatCorrectHTMLTitleIsReturned(expectedTitle: "Kitura Sample", path: "")
    }
}
