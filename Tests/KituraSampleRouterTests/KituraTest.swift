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
import Kitura
import HeliumLogger
import KituraNet

import Dispatch
import Foundation

@testable import Application

class KituraTest: XCTestCase {
    private static let initOnce: () = {
        HeliumLogger.use()
    }()

    override func setUp() {
        KituraTest.initOnce
    }

    override func tearDown() {
    }

    func performServerTest(asyncTasks: (XCTestExpectation) -> Void...) {
        do {
            let app = try App()
            try app.postInit()
            let router = app.router
            Kitura.addHTTPServer(onPort: 8080, with: router)
            Kitura.start()
        } catch {
            XCTFail("Failed to create server")
            return
        }

        let requestQueue = DispatchQueue(label: "Request queue")

        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(index)
            requestQueue.async() {
                asyncTask(expectation)
            }
        }

        waitExpectation(timeout: 10) { error in
            // blocks test until request completes
            Kitura.stop()
            XCTAssertNil(error)
        }
    }

    func performRequest(_ method: String, path: String,  expectation: XCTestExpectation,
                        headers: [String: String]? = nil,
                        requestModifier: ((ClientRequest) -> Void)? = nil,
                        callback: @escaping (ClientResponse) -> Void) {
        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }
        let options: [ClientRequest.Options] =
            [.method(method), .hostname("localhost"), .port(8080), .path(path), .headers(allHeaders)]
        let req = HTTP.request(options) { response in
            guard let response = response else {
                XCTFail("response object is nil")
                expectation.fulfill()
                return
            }
            callback(response)
        }
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end()
    }
    
    func performRequest(_ method: String,
                        path: String,
                        body: String,
                        expectation: XCTestExpectation,
                        headers: [String: String]? = nil,
                        callback: @escaping (ClientResponse) -> Void) {
        self.performRequest(method,
                            path: path,
                            expectation: expectation,
                            headers: headers,
                            requestModifier: { request in
                                request.write(from: body)
                            }
        ) { response in
            callback(response)
        }
    }

    func expectation(_ index: Int) -> XCTestExpectation {
        let expectationDescription = "\(type(of: self))-\(index)"
        return self.expectation(description: expectationDescription)
    }

    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?) {
        self.waitForExpectations(timeout: t, handler: handler)
    }
    
    func runTestThatCorrectHTMLTitleIsReturned(expectedTitle: String, path: String) {
        let pattern = "<title>(.*?)</title>"
        
        runGetResponseTest(path: path) { body in
            do {
                #if os(Linux) && !swift(>=3.1)
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
                                                        range: NSMakeRange(0, body.count))
                
                guard let match = matches.first else {
                    XCTFail("no match of title tag in body")
                    return
                }
                
                let titleRange = match.range(at: 1)
                let titleInBody = NSString(string: body).substring(with: titleRange)
                XCTAssertEqual(titleInBody, expectedTitle,
                               "returned title does not match the expected one")
            } catch {
                XCTFail("failed to create regular expression: \(error)")
            }
        }
    }
    
    typealias BodyChecker =  (String) -> Void
    func checkResponse(response: ClientResponse,
                       expectedResponseText: String? = nil,
                       expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK,
                       bodyChecker: BodyChecker? = nil) {
        XCTAssertEqual(response.statusCode, expectedStatusCode, "No success status code returned")
        if let optionalBody = try? response.readString(), let body = optionalBody {
            if let expectedResponseText = expectedResponseText {
                XCTAssertEqual(body, expectedResponseText, "mismatch in body")
            }
            bodyChecker?(body)
        } else {
            XCTFail("No response body")
        }
    }
    
    func runGetResponseTest(path: String, expectedResponseText: String? = nil,
                            expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK,
                            bodyChecker: BodyChecker? = nil) {
        performServerTest { expectation in
            self.performRequest("get", path: path, expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: expectedResponseText,
                                   expectedStatusCode: expectedStatusCode, bodyChecker: bodyChecker)
                expectation.fulfill()
            }
        }
    }
    
    func runTestUser(expectedUser: String, expectation: XCTestExpectation) {
        self.performRequest("get", path: "/hello", expectation: expectation) {
            response in
            self.checkResponse(response: response,
                               expectedResponseText: "Hello \(expectedUser), from Kitura!")
            expectation.fulfill()
        }
    }

    
    func runTestModifyUser(method: String, userToSet: String? = nil,
                           expectation: XCTestExpectation) {
        self.performRequest(method, path: "/hello", expectation: expectation,
                            requestModifier: { request in
                                if let userToSet = userToSet {
                                    request.write(from: userToSet)
                                }
        }) { response in
            self.checkResponse(response: response,
                               expectedResponseText: "Got a \(method.uppercased()) request")
            expectation.fulfill()
        }
    }
    
    func runGetCodableResponseTest(path: String, expectedResponse: [Book]? = nil, expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK) {
        performServerTest { expectation in
            self.performRequest("get", path: path, expectation: expectation) { response in
                self.checkCodableResponse(response: response, expectedResponse: expectedResponse,
                                          expectedStatusCode: expectedStatusCode)
                expectation.fulfill()
            }
        }
    }
    
    func checkCodableResponse(response: ClientResponse, expectedResponse: [Book]? = nil,
                              expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK) {
        XCTAssertEqual(response.statusCode, expectedStatusCode,
                       "No success status code returned")
        if let optionalBody = try? response.readString(), let body = optionalBody {
            if body.isEmpty {
                XCTAssertNil(expectedResponse)
            } else {
                let json = body.data(using: .utf8)!
                do {
                    let myStruct = try JSONDecoder().decode([Book].self, from: json)
                    if let expectedBooks = expectedResponse {
                        XCTAssertTrue(myStruct.elementsEqual(expectedBooks))
                    }
                } catch {
                    print("Error")
                }
            }
        } else {
            XCTFail("No response body")
        }
    }
    
    func runTestParameter(user: String) {
        let userInPath = user.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? user
        let responseText = "<!DOCTYPE html><html><body><b>User:</b> \(user)</body></html>\n\n"
        runGetResponseTest(path: "/users/\(userInPath)", expectedResponseText: responseText)
    }
}
