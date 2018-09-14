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
import SwiftKueryPostgreSQL
import LoggerAPI

func initializeDatabaseRoutes(app: App) {
    let pool = PostgreSQLConnection.createPool(host: "localhost", port: 5432, options: [.databaseName("school")], poolOptions: ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 5, timeout: 10000))
    Database.default = Database(pool)
    do {
        try Grade.createTableSync()
    } catch let error {
        Log.error("Failed to create table in database: \(error)")
    }
    
    app.router.get("/grades", handler: app.loadHandler)
    app.router.get("/grades", handler: app.getOneHandler)
    app.router.post("/grades", handler: app.postHandler)
    app.router.delete("/grades", handler: app.deleteAllHandler)
    app.router.delete("/grades", handler: app.deleteOneHandler)
}

extension App {
    func loadHandler(query: GradesQuery?, completion: @escaping([Grade]?, RequestError?) -> Void) {
        Grade.findAll(matching: query, completion)
    }
    
    func getOneHandler(id: Int, completion: @escaping (Grade?, RequestError?) -> Void ) {
        Grade.find(id: id, completion)
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
