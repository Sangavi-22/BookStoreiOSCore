
import Foundation
import SQLite3

class DBHelper{
    var db: OpaquePointer?
    
    deinit{
        sqlite3_close(db)
    }
    
    func openDatabase(completionHandler: (OpaquePointer?) -> Void){
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("myBookStore.sqlite")
        
        if sqlite3_open(filePath.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(filePath.path)")
            _ = performOperationOnTable(with: "PRAGMA foreign_keys = ON")
        }
        
        completionHandler(db)
    }
    
    func performOperationOnTable(with query: String) -> Result<Void, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK, executionResult == SQLITE_DONE{
            return .success(())
        }
        else{
            guard let sqliteError = SQLiteError(errorCode: queryPreparationResult) else {
                return .failure(.generic)
            }
            return .failure(sqliteError)
        }
    }
   
}










//func performOperationOnTable(with query: String, toPerform operation: String) -> SqliteResult {
//    var statement: OpaquePointer?
//    defer { sqlite3_finalize(statement) }
//
//    let result = sqlite3_prepare_v2(db, query, -1, &statement, nil)
//    if result == SQLITE_OK {
//        return SqliteResult.ok
//    } else {
//        let sqliteError = SqliteError(errorCode: result)!
//        return SqliteResult.error(type: sqliteError)
//    }
//
//
//    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK, sqlite3_step(statement) == SQLITE_DONE{
//        print("\n\(operation) perfomed")
//    }
//    else{
//        let message = "\(operation) failed"
//        throw DataValidationError.runTimeError(message)
//    }
//
//}
//
//enum SqliteResult {
//    case ok
//    case error(type: SqliteError)
//}
//
//enum SqliteError {
//    case unknow
//    case internalLogicError
//    case abort
//    case databaseFull
//
//    init?(errorCode: Int32) {
//        switch errorCode {
//        case SQLITE_ABORT:
//            self = .abort
//        case SQLITE_INTERNAL:
//            self = .internalLogicError
//        default: fatalError()
//        }
//    }
//}
