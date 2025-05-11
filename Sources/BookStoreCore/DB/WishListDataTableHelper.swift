

import Foundation
import SQLite3

class WishListDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
       "CREATE TABLE if not exists WishList(id INTEGER PRIMARY KEY AUTOINCREMENT, userId TEXT, bookId TEXT, CONSTRAINT foreign_key1 FOREIGN KEY(userId) REFERENCES AccountDetails(userId) ON DELETE CASCADE, CONSTRAINT foreign_key2 FOREIGN KEY(bookId) REFERENCES LibraryBooks(id) ON DELETE CASCADE);"
    }
    
    func createInsertStatement(with bookId: String, for userId: String) -> String{
        "INSERT INTO WishList(userId, bookId) VALUES ('\(userId)', '\(bookId)');"
    }
    
    func createDeleteStatement(with bookId: String, for userId: String) -> String{
        "DELETE FROM WishList WHERE userId = '\(userId)' AND bookId = '\(bookId)';"
    }
    
    func fetchWishListedBooks(for userId: String) -> Result<[String], SQLiteError>{
        var queryStatement: OpaquePointer?
        defer { sqlite3_finalize(queryStatement) }
        
        var list: [String] = []
        let queryStatementString = "SELECT * FROM WishList;"
        let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
        
        if queryPreparationResult == SQLITE_OK{
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let result1 = sqlite3_column_text(queryStatement, 1)!
                let id = String(cString: result1)
                
                let result2 = sqlite3_column_text(queryStatement, 2)!
                let bookId = String(cString: result2)
                
                if id == userId{
                    list.append(bookId)
                }
            }
            return .success(list)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
  
}
 


