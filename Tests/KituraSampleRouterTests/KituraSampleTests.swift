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
            ("testMultiplicity", testMulitplicity)
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
            self.performRequest("get", path: "/users/:user") { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }
        }
    }

    func testMulitplicity() {
        performServerTest { expectation in
            self.performRequest("get", path: "/multi") { response in
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "Route did not match")
                expectation.fulfill()
            }
        }
    }
}
