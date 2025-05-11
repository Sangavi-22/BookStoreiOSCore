
import Foundation
import SQLite3

class OrdersDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists OrderDetails(orderId TEXT PRIMARY KEY, userId TEXT, bookId TEXT, dateOfDelivery TEXT, dateOfReturn TEXT, transactionStatus TEXT, CONSTRAINT foreign_key1 FOREIGN KEY(userId) REFERENCES AccountDetails(userId) ON DELETE CASCADE, CONSTRAINT foreign_key2 FOREIGN KEY(bookId) REFERENCES LibraryBooks(id) ON DELETE CASCADE);"
    }
    
    func createInsertStatement(with order: BookOrder) -> String{
        let formattedDeliveryDate = DateUtils.convertDateToString(input: order.bookDeliveryDate, pattern: .dayDateMonthYear)
        
        let formattedReturnDate = DateUtils.convertDateToString(input: order.bookReturnDate, pattern: .dayDateMonthYear)
        
        return "INSERT INTO OrderDetails(orderId, userId, bookId, dateOfDelivery, dateOfReturn, transactionStatus) VALUES ('\(order.orderId)', '\(order.userId)', '\(order.bookId)', '\(formattedDeliveryDate)', '\(formattedReturnDate)', '\(order.transactionStatus.rawValue)');"
    }
    
    func createUpdateStatement(with order: BookOrder) -> String{
        let formattedDeliveryDate = DateUtils.convertDateToString(input: order.bookDeliveryDate, pattern: .dayDateMonthYear)
        
        let formattedReturnDate = DateUtils.convertDateToString(input: order.bookReturnDate, pattern: .dayDateMonthYear)
        
        return "UPDATE OrderDetails SET dateOfDelivery = '\(formattedDeliveryDate)', dateOfReturn = '\(formattedReturnDate)', transactionStatus = '\(order.transactionStatus.rawValue)' where orderId = '\(order.orderId)';"
    }
    
    func createDeleteStatement(with order: BookOrder) -> String{
        "DELETE FROM OrderDetails WHERE orderId = '\(order.orderId)';"
    }
    
    func fetchOrdersCount() -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT COUNT(1) FROM OrderDetails"
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
    
    func fetchOrderDetails() -> Result<[BookOrder], SQLiteError>{
        var queryStatement: OpaquePointer?
        defer { sqlite3_finalize(queryStatement) }
        
        var list: [BookOrder] = []
        let queryStatementString = "SELECT * FROM OrderDetails;"
        let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
        
        if queryPreparationResult == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let result1 = sqlite3_column_text(queryStatement, 0)!
                let orderId = String(cString: result1)
                
                let result2 = sqlite3_column_text(queryStatement, 1)!
                let userId = String(cString: result2)
                
                let result3 = sqlite3_column_text(queryStatement, 2)!
                let bookId = String(cString: result3)
                
                let result4 = sqlite3_column_text(queryStatement, 3)!
                let dateOfDelivery = DateUtils.convertStringToDate(input: String(cString: result4), pattern: .dayDateMonthYear)
                
                let result5 = sqlite3_column_text(queryStatement, 4)!
                let dateOfReturn = DateUtils.convertStringToDate(input: String(cString: result5), pattern: .dayDateMonthYear)
                
                let result6 = sqlite3_column_text(queryStatement, 5)!
                let transactionStatus = TransactionStatus(rawValue: String(cString: result6)) ?? .borrowed
                
                let order = BookOrder(orderId: orderId, userId: userId, bookId: bookId, bookDeliveryDate: dateOfDelivery, bookReturnDate: dateOfReturn, transactionStatus: transactionStatus)
                list.append(order)
            }
            return .success(list)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
}
 
