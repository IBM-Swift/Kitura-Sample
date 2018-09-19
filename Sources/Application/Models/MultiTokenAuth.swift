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

import Credentials
import CredentialsGoogle
import CredentialsFacebook

struct MultiTokenAuth: TypeSafeMultiCredentials {
    
    static var authenticationMethods: [TypeSafeCredentials.Type] = [GoogleTokenProfile.self, FacebookTokenProfile.self]
    
    let id: String
    let name: String
    let provider: String
    
    init(successfulAuth: TypeSafeCredentials) {
        self.id = successfulAuth.id
        self.provider = successfulAuth.provider
        switch successfulAuth {
            case let googleToken as GoogleTokenProfile:
                self.name = googleToken.name
            case let facebookToken as FacebookTokenProfile:
                self.name = facebookToken.name
            default:
                self.name = successfulAuth.id
        }
    }
}
