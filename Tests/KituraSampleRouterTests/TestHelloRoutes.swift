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

class TestHelloRoutes: KituraTest {
    static var allTests: [(String, (TestHelloRoutes) -> () throws -> Void)] {
        return [
            ("testGetHello", testGetHello),
            ("testPostHello", testPostHello),
            ("testDeleteHello", testDeleteHello),
            ("testPostDeletePostHello", testPostDeletePostHello),
            ("testPostDeleteHello", testPostDeleteHello),
        ]
    }
    
    func testGetHello() {
        performServerTest(asyncTasks: { expectation in
            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                expectation.fulfill()
            }
        })
    }
    
    func testPostHello() {
        performServerTest(asyncTasks: { expectation in
            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                self.performRequest("post", path: "/hello", body: "{\"name\" : \"John\"}", expectation: expectation) { response in
                    self.checkResponse(response: response, expectedResponseText: "{\"name\":\"John\"}")
                    self.performRequest("get", path: "/hello", expectation: expectation) { response in
                        self.checkResponse(response: response, expectedResponseText: "Hello John, from Kitura!")
                        expectation.fulfill()
                    }
                }
            }
        })
    }
    
    func testDeleteHello() {
        performServerTest(asyncTasks: { expectation in
            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                self.performRequest("delete", path: "/hello", expectation: expectation) { response in
                    self.checkResponse(response: response, expectedResponseText: "Got a DELETE request")
                    self.performRequest("get", path: "/hello", expectation: expectation) { response in
                        self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                        expectation.fulfill()
                    }
                }
            }
        })
    }
    
    func testPostDeletePostHello() {
        performServerTest(asyncTasks: { expectation in
            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                self.performRequest("post", path: "/hello", body: "{\"name\":\"John\"}", expectation: expectation) { response in
                    self.checkResponse(response: response, expectedResponseText: "{\"name\":\"John\"}")
                    self.performRequest("get", path: "/hello", expectation: expectation) { response in
                        self.checkResponse(response: response, expectedResponseText: "Hello John, from Kitura!")
                        self.performRequest("delete", path: "/hello", expectation: expectation) { response in
                            self.checkResponse(response: response, expectedResponseText: "Got a DELETE request")
                            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                                self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                                self.performRequest("post", path: "/hello", body: "{\"name\":\"Bob\"}", expectation: expectation) { response in
                                    self.checkResponse(response: response, expectedResponseText: "{\"name\":\"Bob\"}")
                                    self.performRequest("get", path: "/hello", expectation: expectation) { response in
                                        self.checkResponse(response: response, expectedResponseText: "Hello Bob, from Kitura!")
                                        expectation.fulfill()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func testPostDeleteHello() {
        performServerTest(asyncTasks: { expectation in
            self.performRequest("get", path: "/hello", expectation: expectation) { response in
            self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                self.performRequest("post", path: "/hello", body: "{\"name\":\"Mary\"}", expectation: expectation) { response in
                self.checkResponse(response: response, expectedResponseText: "{\"name\":\"Mary\"}")
                    self.performRequest("get", path: "/hello", expectation: expectation) { response in
                    self.checkResponse(response: response, expectedResponseText: "Hello Mary, from Kitura!")
                        self.performRequest("delete", path: "/hello", expectation: expectation) { response in
                        self.checkResponse(response: response, expectedResponseText: "Got a DELETE request")
                            self.performRequest("get", path: "/hello", expectation: expectation) { response in
                            self.checkResponse(response: response, expectedResponseText: "Hello World, from Kitura!")
                                    expectation.fulfill()
                            }
                        }
                    }
                }
            }
        })
    }
}
