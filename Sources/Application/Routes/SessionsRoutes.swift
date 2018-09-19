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
        let bookData = session["books"] as? [[String: String]] ?? []
        var books: [Book] = []
        for book in bookData {
            guard let bookName = book["name"],
                  let bookAuthor = book["author"],
                  let ratingString = book["rating"],
                  let bookRating = Int(ratingString)
            else { continue }
            let newBook = Book(name: bookName, author: bookAuthor, rating: bookRating)
            books.append(newBook)
        }
        response.send(json: books)
        next()
    }
    
    app.router.post("/rawsession") { request, response, next in
        guard let session = request.session else {
            return try response.status(.internalServerError).end()
        }
        var bookData = session["books"] as? [[String: String]] ?? []
        let inputBook = try request.read(as: Book.self)
        let bookDict: [String: String] = ["name": inputBook.name, "author": inputBook.author, "rating": String(inputBook.rating)]
        bookData.append(bookDict)
        session["books"] = bookData
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
