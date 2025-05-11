
import Foundation
import SQLite3

class NotificationsDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists Notifications(identifier TEXT PRIMARY KEY, bookId TEXT, date TEXT, targetedUser TEXT, status TEXT, CONSTRAINT foreign_key1 FOREIGN KEY(bookId) REFERENCES LibraryBooks(id) ON DELETE CASCADE);"
    }
    
    func createInsertStatement(with notification: RegisteredNotification) -> String{
        let formattedNotificationDate = DateUtils.convertDateToString(input: notification.dateGenerated, pattern: .dayDateMonthYear)
        
        return  "INSERT INTO Notifications(identifier, bookId, date, targetedUser, status) VALUES ('\(notification.notificationIdentifier)', '\(notification.bookId)', '\(formattedNotificationDate)', '\(notification.targetedUser.rawValue)', '\(notification.status)');"
    }
    
    func createUpdateStatement(withData notification: RegisteredNotification) -> String{
        "UPDATE Notifications SET status = '\(notification.status)' where identifier = '\(notification.notificationIdentifier)';"
    }
    
    func fetchNotificationsCount() -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT COUNT(1) FROM Notifications"
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK,
           executionResult == SQLITE_ROW{
            let count = Int(sqlite3_column_int(statement, 0))
            return .success(count)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
    
    func fetchNotifications() -> Result<[RegisteredNotification], SQLiteError>{
        var queryStatement: OpaquePointer?
        defer { sqlite3_finalize(queryStatement) }
        
        var list: [RegisteredNotification] = []
        let queryStatementString = "SELECT * FROM Notifications;"
        let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
        
        if queryPreparationResult == SQLITE_OK{
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let result1 = sqlite3_column_text(queryStatement, 0)!
                let identifier = String(cString: result1)
                
                let result2 = sqlite3_column_text(queryStatement, 1)!
                let bookId = String(cString: result2)
                
                let result3 = sqlite3_column_text(queryStatement, 2)!
                let date = DateUtils.convertStringToDate(input: String(cString: result3), pattern: .dayDateMonthYear)
                
                let result4 = sqlite3_column_text(queryStatement, 3)!
                let targetedUser = Role(rawValue: String(cString: result4))!
                
                let result5 = sqlite3_column_text(queryStatement, 4)!
                let status = NotificationStatus(rawValue: String(cString: result5))!
                
                let notification = RegisteredNotification(notificationIdentifier: identifier, bookId: bookId, dateGenerated: date, targetedUser: targetedUser, status: status)
                
                list.append(notification)
            }
            return .success(list)
        }
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }

}
