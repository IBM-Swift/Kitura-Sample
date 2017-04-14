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

import KituraSampleRouter

class KituraTest: XCTestCase {
    private static let initOnce: () = {
        HeliumLogger.use()
    }()

    override func setUp() {
        KituraTest.initOnce
    }

    override func tearDown() {
    }

    func performServerTest(asyncTasks: @escaping (XCTestExpectation) -> Void...) {
        let router = RouterCreator.create()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.start()

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

    func performRequestSynchronous(_ method: String, path: String,  expectation: XCTestExpectation,
                        headers: [String: String]? = nil,
                        requestModifier: ((ClientRequest) -> Void)? = nil,
                        callback: @escaping (ClientResponse, DispatchGroup) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        performRequest(method, path: path, expectation: expectation, headers: headers,
                       requestModifier: requestModifier) { response in
                        callback(response, dispatchGroup)
        }
        dispatchGroup.wait()
    }

    func expectation(_ index: Int) -> XCTestExpectation {
        let expectationDescription = "\(type(of: self))-\(index)"
        return self.expectation(description: expectationDescription)
    }

    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?) {
        self.waitForExpectations(timeout: t, handler: handler)
    }
}
