
import Foundation
import SQLite3

class GenresDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists Genres(genre TEXT PRIMARY KEY);"
    }
    
    func createInsertStatement(withData genre: String) -> String{
        "INSERT INTO Genres(genre) VALUES ('\(genre)');"
    }
    
    func createUpdateStatement(withPreviousName oldGenreName: String, newName newGenreName: String) -> String{
        "UPDATE Genres SET genre = '\(newGenreName)' where genre = '\(oldGenreName)';"
    }
    
    func createDeleteStatement(withData genre: String) -> String{
        "DELETE FROM Genres WHERE genre = '\(genre)';"
    }
    
    func fetchAllGenres() -> Result<[String], SQLiteError>{
        var queryStatement: OpaquePointer?
        defer { sqlite3_finalize(queryStatement) }
        
        var list: [String] = []
        let queryStatementString = "SELECT * FROM Genres;"
        let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
        
        if queryPreparationResult == SQLITE_OK{
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResult = sqlite3_column_text(queryStatement, 0)!
                let category = String(cString: queryResult)
                list.append(category)
            }
            return .success(list)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }

}
    
