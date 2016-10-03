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
import Foundation

@testable import Kitura
@testable import KituraNet

class KituraSampleTests: XCTestCase {
    
    static var allTests: [(String, (KituraSampleTests) -> () throws -> Void)] {
        return [
            ("testURLParameters", testURLParameters),
            ("testCustomMiddlewareURLParameter", testCustomMiddlewareURLParameter),
            ("testCustomMiddlewareURLParameterWithQueryParam", testCustomMiddlewareURLParameterWithQueryParam),
            ("testMultiplicity", testMulitplicity)
        ]
    }
    

    
    override func setUp() {
        doSetUp()
    }
    
    override func tearDown() {
        doTearDown()
    }
    
    let router = KituraSampleTests.setupRouter()
    
    func testURLParameters() {
        // Set up router for this test
        let router = Router()
        
        router.get("/users/qwerty") { request, _, next in
            let parameter = request.parameters["user"]
            XCTAssertNotNil(parameter, "URL paramter was nil")
            XCTAssertEqual(parameter, "qwerty")
            next()
        }

        router.all() { _, response, next in
            response.status(.OK).send("OK")
            next()
        }
        
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/users/:user", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }
    }
    
    func testMulitplicity() {
        performServerTest(router, asyncTasks: { expecatation in
            self.performRequest("get", path: "/multi", callback: {response in
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "Route did not match")
                expecatation.fulfill()
            })
        })
    }
    
    private func runMiddlewareTest(path: String) {
        class CustomMiddleware: RouterMiddleware {
            func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
                let id = request.parameters["id"]
                XCTAssertNotNil(id, "URL parameter 'id' in custom middleware was nil")
                XCTAssertEqual("my_custom_id", id, "URL parameter 'id' in custom middleware was wrong")
                response.status(.OK)
                next()
            }
        }
        
        let router = Router()
        
        router.get("/user/:id", allowPartialMatch: false, middleware: CustomMiddleware())
        router.get("/user/:id") { request, response, next in
            let id = request.parameters["id"]
            XCTAssertNotNil(id, "URL parameter 'id' in middleware handler was nil")
            XCTAssertEqual("my_custom_id", id, "URL parameter 'id' in middleware handler was wrong")
            response.status(.OK)
            next()
        }
        
        performServerTest(router) { expectation in
            self.performRequest("get", path: path, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }
    }
    
    func testCustomMiddlewareURLParameter() {
        runMiddlewareTest(path: "/user/my_custom_id")
    }
    
    func testCustomMiddlewareURLParameterWithQueryParam() {
        runMiddlewareTest(path: "/user/my_custom_id?some_param=value")
    }
    
    static func setupRouter() -> Router {
        let router = Router()
        
        // Uses multiple handler blocks
        router.get("/multi", handler: { request, response, next in
            response.send("I'm here!\n")
            next()
            }, { request, response, next in
                response.send("Me too!\n")
                next()
        })
        router.get("/multi") { request, response, next in
            try response.send("I come afterward..\n").end()
        }
        
        router.get("/users/:user") { request, response, next in
            response.headers["Content-Type"] = "text/html"
            request.parameters["user"] = "rob"
            let p1 = request.parameters["user"] ?? "(nil)"
            try response.send(
                "<!DOCTYPE html><html><body>" +
                    "<b>User:</b> \(p1)" +
                "</body></html>\n\n").end()
        }
        
        return router
    }
}
