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

import KituraContracts
import KituraSession
func initializeSessionsRoutes(app: App) {
    // Codable Session
    app.router.get("/session") { (session: MySession, respondWith: ([Book]?, RequestError?) -> Void) -> Void in
        respondWith(session.books, nil)
    }

    app.router.post("/session") { (session: MySession, book: Book, respondWith: (Book?, RequestError?) -> Void) -> Void in
        session.books.append(book)
        session.save()
        respondWith(book, nil)
    }
    
    app.router.delete("/session") { (session: MySession, respondWith: (RequestError?) -> Void) -> Void in
        session.destroy()
        respondWith(nil)
    }
    
    // Raw session
    let session = Session(secret: "secret", cookie: [CookieParameter.name("Raw-cookie")])
    app.router.all(middleware: session)
    
    app.router.get("/rawsession") { request, response, next in
        guard let session = request.session else {
            return try response.status(.internalServerError).end()
        }
        let books: [Book] = session["books"] ?? []
        response.send(json: books)
        next()
    }
    
    app.router.post("/rawsession") { request, response, next in
        guard let session = request.session else {
            return try response.status(.internalServerError).end()
        }
        var books: [Book] = session["books"] ?? []
        let inputBook = try request.read(as: Book.self)
        books.append(inputBook)
        session["books"] = books
        response.status(.created)
        response.send(inputBook)
        next()
    }
    
    app.router.delete("/rawsession") { request, response, next in
        guard let session = request.session else {
            return try response.status(.internalServerError).end()
        }
        session["books"] = nil
        let _ = response.send(status: .noContent)
        next()
    }
}
