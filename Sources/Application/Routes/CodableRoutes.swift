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

func initializeCodableRoutes(app: App) {
    
   //Codable route for post
<<<<<<< HEAD
    app.router.post("/books", handler: app.persistBookHandler)

    //Codable route for get with and without parameters
    app.router.get("/books", handler: app.queryGetHandler)
}
extension App {
    func persistBookHandler(book: Book, completion: (Book?, RequestError?) -> Void ) {
        addBook(book)
        completion(book, nil)
    }
    
    func queryGetHandler(query: BookQuery, respondWith: ([Book]?, RequestError?) -> Void) {
        // Filter data using query parameters provided to the application
        if let bookName = query.name {
            let books = getBooks().filter { $0.name == bookName }
            return respondWith(books, nil)
        } else {
            return respondWith(getBooks(), nil)
        }
    }
    
    func addBook(_ book: Book) {
        bookSemaphore.wait()
        bookStore.append(book)
        bookSemaphore.signal()
    }
    
    func getBooks() -> [Book] {
        bookSemaphore.wait()
        let safeBooks = bookStore
        nameSemaphore.signal()
        return safeBooks
=======
    app.router.get("/books", handler: app.queryGetHandler)
    app.router.post("/books", handler: app.postBookHandler)
    app.router.put("/books", handler: app.putBookHandler)
    app.router.delete("/books", handler: app.deleteAllBookHandler)
}

extension App {
    func queryGetHandler(query: BookQuery, respondWith: ([Book]?, RequestError?) -> Void) {
        // Filter data using query parameters provided to the application
        if let bookName = query.name {
            let books = bookStore.filter { $0.name == bookName }
            return respondWith(books, nil)
        } else {
            return respondWith(bookStore, nil)
        }
    }

    func postBookHandler(book: Book, completion: (Book?, RequestError?) -> Void ) {
        execute {
            bookStore.append(book)
        }
        completion(book, nil)
    }

    func putBookHandler(bookIndex: Int, book: Book, completion: (Book?, RequestError?) -> Void ) {
        execute {
            bookStore[bookIndex] = book
        }
        completion(bookStore[bookIndex], nil)
    }

    func deleteAllBookHandler(completion: (RequestError?) -> Void) {
        execute {
            bookStore = []
        }
        return completion(nil)
    }
    
    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
>>>>>>> added sessions and authentication
    }
}
