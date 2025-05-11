

import Foundation
import SQLite3

class BorrowedCountDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists BorrowedCount(id INTEGER PRIMARY KEY AUTOINCREMENT, userId TEXT, count INTEGER, CONSTRAINT foreign_key1 FOREIGN KEY(userId) REFERENCES AccountDetails(userId) ON DELETE CASCADE);"
    }
    
    func createInsertStatement(with count: Int, for userId: String) -> String{
        "INSERT INTO BorrowedCount(userId, count) VALUES ('\(userId)', '\(count)');"
    }
    
    func createUpdateStatement(with count: Int, for userId: String) -> String{
        "UPDATE BorrowedCount SET count = '\(count)' where userId = '\(userId)';"
    }
    
    func fetchBorrowedCount(of userId: String) -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT * FROM BorrowedCount WHERE userId = \(userId)"
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK, executionResult == SQLITE_ROW{
            let borrowedCount = Int(sqlite3_column_int(statement, 2))
            return .success(borrowedCount)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
}
 
