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

import SwiftKuery

// This code does NOT demonstrate standard Kuery or ORM usage.
// This class is a dummy SwiftKuery plugin that allows the saving and retrieval of "Grade" objects in local storage.
// This allows the Database example to run prior to connecting to a real database.
class DummyConnection: Connection {
    func execute(preparedStatement: PreparedStatement, parameters: [String : Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    var grades = [Grade]()
    
    func execute(query: Query, onCompletion: @escaping ((QueryResult) -> ())) {
        do {
            let queryComponents = (try query.build(queryBuilder: queryBuilder)).components(separatedBy: " ")
            switch queryComponents[0] {
            case "SELECT":
                if queryComponents[1] == "*" {
                    if grades.isEmpty {
                        return onCompletion(.successNoData)
                    } else {
                    return onCompletion(QueryResult.resultSet(ResultSet(DummyResultFetcher(grades: grades), connection: self)))
                    }
                }
            case "DELETE":
                grades = []
                return onCompletion(.successNoData)
            default:
                return onCompletion(.successNoData)
            }
        } catch {
            onCompletion(QueryResult.error(error))
        }
    }
    
    func execute(query: Query, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        do {
            let queryComponents = (try query.build(queryBuilder: queryBuilder)).components(separatedBy: " ")
            switch queryComponents[0] {
            case "INSERT":
                if let course = parameters[0] as? String, let grade = parameters[1] as? Int {
                    grades.append(Grade(course: course, grade: grade))
                }
                return onCompletion(.successNoData)
            case "SELECT":
                if let course = parameters[0] as? String {
                    let matchingGrades = grades.filter { $0.course == course }
                    return onCompletion(.resultSet(ResultSet(DummyResultFetcher(grades: matchingGrades), connection: self)))
                }
            default:
                return onCompletion(QueryResult.successNoData)
            }
        } catch {
            onCompletion(QueryResult.error(error))
        }
    }
    
    func execute(_ raw: String, onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    func execute(_ raw: String, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    func execute(query: Query, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    func execute(_ raw: String, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ()))  {
        onCompletion(.successNoData)
    }
    
    func descriptionOf(query: Query) -> String {
        return (try? query.build(queryBuilder: queryBuilder)) ?? ""
    }
    
    func execute(preparedStatement: PreparedStatement, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    func execute(preparedStatement: PreparedStatement, onCompletion: @escaping ((QueryResult) -> ())) {
        onCompletion(.successNoData)
    }
    
    init(withDeleteRequiresUsing: Bool = false, withUpdateRequiresFrom: Bool = false) {
        self.queryBuilder = QueryBuilder(columnBuilder: DummySQLColumnBuilder())
    }
    
    var queryBuilder: QueryBuilder
    
    func connect(onCompletion: @escaping (QueryResult) -> ()) {}
    
    func connectSync() -> QueryResult { return QueryResult.successNoData }
    func closeConnection() {}
    
    var isConnected: Bool = true
    
    func prepareStatement(_ query: Query, onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func prepareStatement(_ raw: String, onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func release(preparedStatement: PreparedStatement, onCompletion: @escaping ((QueryResult) -> ())) {}
        
    func startTransaction(onCompletion: @escaping ((QueryResult) -> ())) { }
    
    func commit(onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func rollback(onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func create(savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func rollback(to savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}
    
    func release(savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}
    
}

class DummyResultFetcher: ResultFetcher {
    let numberOfRows: Int
    let titles = ["course", "grade"]
    var rows = [[Any]]()
    var fetched = 0
    
    init(grades: [Grade]) {
        numberOfRows = grades.count
        for grade in grades {
            rows.append([grade.course, Int32(grade.grade)])
        }
    }
    
    func fetchNext(callback: @escaping (([Any?]?, Error?)) -> ()) {
        if fetched < numberOfRows {
            fetched += 1
            callback((rows[fetched - 1], nil))
        }
        callback((nil, nil))
    }
    
    func fetchTitles(callback: @escaping (([String]?, Error?)) -> ()) {
        callback((titles, nil))
    }
    
    func done() {}
}

class DummySQLColumnBuilder: ColumnCreator {
    func buildColumn(for column: Column, using queryBuilder: QueryBuilder) -> String? {
        guard let type = column.type else {
            return nil
        }
        
        var result = column.name
        let identifierQuoteCharacter = queryBuilder.substitutions[QueryBuilder.QuerySubstitutionNames.identifierQuoteCharacter.rawValue]
        if !result.hasPrefix(identifierQuoteCharacter) {
            result = identifierQuoteCharacter + result + identifierQuoteCharacter + " "
        }
        
        var typeString = type.create(queryBuilder: queryBuilder)
        if let length = column.length {
            typeString += "(\(length))"
        }
        
        if column.isPrimaryKey {
            result += " PRIMARY KEY"
        }
        if column.isNotNullable {
            result += " NOT NULL"
        }
        if column.isUnique {
            result += " UNIQUE"
        }
        if let checkExpression = column.checkExpression {
            result += checkExpression.contains(column.name) ? " CHECK (" + checkExpression.replacingOccurrences(of: column.name, with: "\"\(column.name)\"") + ")" : " CHECK (" + checkExpression + ")"
        }
        if let collate = column.collate {
            result += " COLLATE \"" + collate + "\""
        }
        return result
    }
    
    
}
