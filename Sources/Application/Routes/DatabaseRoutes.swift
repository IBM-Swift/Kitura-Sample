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

import Foundation
import SwiftKueryORM
import LoggerAPI
// If using PostgreSQL, uncomment the dependancy in Package.swift and import SwiftKueryPostgreSQL here:
//import SwiftKueryPostgreSQL

/*
 To connect these routes to a running database you need postgresql (Or an alternative SQL database) running locally on your machine:
 
 brew install postgresql
 brew services start postgresql
 createdb school
 */
func initializeDatabaseRoutes(app: App) {
    // If you have a database running, replace the dummy connection with a real one:
    
    let connection = DummyConnection()
    Database.default = Database(single: connection)
//     let pool = PostgreSQLConnection.createPool(host: "localhost", port: 5432, options: [.databaseName("school")], poolOptions: ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 5, timeout: 10000))
//     Database.default = Database(pool)

    do {
        try Grade.createTableSync()
    } catch let error {
        Log.error("Failed to create table in database: \(error)")
    }
    
    app.router.get("/database", handler: app.loadHandler)
    app.router.post("/database", handler: app.postHandler)
    app.router.delete("/database", handler: app.deleteAllHandler)
    app.router.delete("/database", handler: app.deleteOneHandler)
}

extension App {
    func loadHandler(query: GradesQuery?, completion: @escaping([Grade]?, RequestError?) -> Void) {
        Grade.findAll(matching: query, completion)
    }
    
    func postHandler(grade: Grade, completion: @escaping (Grade?, RequestError?) -> Void ) {
        grade.save(completion)
    }
    
    func deleteAllHandler(completion: @escaping (RequestError?) -> Void ) {
        Grade.deleteAll(completion)
    }
    
    func deleteOneHandler(id: Int, completion: @escaping (RequestError?) -> Void ) {
        Grade.delete(id: id, completion)
    }
}
