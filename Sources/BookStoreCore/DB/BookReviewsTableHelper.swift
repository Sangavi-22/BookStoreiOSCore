

import Foundation
import SQLite3

class BookReviewsDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }

    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists BookReviews(reviewId TEXT PRIMARY KEY, userId TEXT, bookId TEXT, date TEXT, title TEXT, message TEXT, rating INTEGER, CONSTRAINT foreign_key1 FOREIGN KEY(userId) REFERENCES AccountDetails(userId) ON DELETE CASCADE, CONSTRAINT foreign_key2 FOREIGN KEY(bookId) REFERENCES LibraryBooks(id) ON DELETE CASCADE);"
    }
    
    func createInsertStatement(with review: Review) -> String{
        let formattedReviewDate = DateUtils.convertDateToString(input: review.dateGenerated, pattern: .dateMonthYear)
        
        return "INSERT INTO BookReviews(reviewId, userId, bookId, date, title, message, rating) VALUES ('\(review.reviewId)', '\(review.userId)', '\(review.bookId)', '\(formattedReviewDate)', '\(review.title)', '\(review.message)', '\(review.rating)')"
    }
    
    func createUpdateStatement(with review: Review) -> String{
        "UPDATE BookReviews SET title = '\(review.title)', message = '\(review.message)', rating = '\(review.rating)' where reviewId = '\(review.reviewId)';"
    }
    
    func createDeleteStatement(with review: Review) -> String{
        "DELETE FROM BookReviews WHERE reviewId = '\(review.reviewId)';"
    }
    
    func fetchReviewsCount() -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT COUNT(1) FROM BookReviews"
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK,
            executionResult == SQLITE_ROW {
            let count = Int(sqlite3_column_int(statement, 0))
            return .success(count)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
    
    func fetchReviews() -> Result<[Review], SQLiteError>{
        var queryStatement: OpaquePointer?
        defer {  sqlite3_finalize(queryStatement) }
        
        var list: [Review] = []
        let queryStatementString = "SELECT * FROM BookReviews;"
        let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
        
        if queryPreparationResult == SQLITE_OK{
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let result1 = sqlite3_column_text(queryStatement, 0)!
                let reviewId = String(cString: result1)
                
                let result2 = sqlite3_column_text(queryStatement, 1)!
                let userId = String(cString: result2)
                
                let result3 = sqlite3_column_text(queryStatement, 2)!
                let bookId = String(cString: result3)
                
                let result4 = sqlite3_column_text(queryStatement, 3)!
                let date = DateUtils.convertStringToDate(input: String(cString: result4), pattern: .dateMonthYear)
                
                let result5 = sqlite3_column_text(queryStatement, 4)!
                let title = String(cString: result5)
                
                let result6 = sqlite3_column_text(queryStatement, 5)!
                let message = String(cString: result6)
                
                let result7 = sqlite3_column_int(queryStatement, 6)
                let rating = Int(result7)
                
                let review = Review(reviewId: reviewId, userId: userId, bookId: bookId, dateGenerated: date, title: title, message: message, rating: rating)

                list.append(review)
            }
            return .success(list)
        }
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
        
}
    
