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
import Dispatch

public class UserPasswords {
    static let authSemaphore = DispatchSemaphore(value: 1)
    private static var passwords: [String: Int] = ["username": "password".hashValue]
    
    static func addPassword(username: String, password: String) -> Bool {
        authSemaphore.wait()
        if let _ = passwords[username] {
            authSemaphore.signal()
            return false
        } else {
            passwords[username] = password.hashValue
            authSemaphore.signal()
            return true
        }
    }
    
    static func checkPassword(username: String, password: String) -> Bool {
        authSemaphore.wait()
        let optionalPassword = passwords[username]
        authSemaphore.signal()
        guard let hashedPassword = optionalPassword, hashedPassword == password.hashValue  else {
            return false
        }
        return true
    }
    
    static func clearPasswords() {
        authSemaphore.wait()
        passwords = [:]
        authSemaphore.signal()
    }
    
    
}

