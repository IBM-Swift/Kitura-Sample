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

import KituraSession

// Defines the session instance data
final class MySession: TypeSafeSession {
    
    let sessionId: String                       // Requirement: every session must have an ID
    var books: [Book]                           // User-defined type, where Book conforms to Codable
    
    init(sessionId: String) {                   // Requirement: must be able to create a new (empty)
        self.sessionId = sessionId              // session containing just an ID. Assign a default or
        books = []                              // empty value for any non-optional properties.
    }
}

// Defines the configuration of the user's type: how the cookie is constructed, and how the session is
// persisted.
extension MySession {
    static let sessionCookie: SessionCookie = SessionCookie(name: "MySession", secret: "Top Secret")
    static var store: Store?
}
