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

import CredentialsHTTP
import Dispatch

public struct MyBasicAuth: TypeSafeHTTPBasic {
    public static let realm: String = "HTTP Basic authentication: Username = username, Password = password"
    
    public static func verifyPassword(username: String, password: String, callback: @escaping (MyBasicAuth?) -> Void) {
        if UserPasswords.checkPassword(username: username, password: password) {
            callback(MyBasicAuth(id: username))
            return
        }
        callback(nil)
    }
    
    public var id: String
}
