
import Foundation
import SQLite3
import UIKit

class BooksDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists LibraryBooks(id TEXT PRIMARY KEY, title TEXT, author TEXT, genre TEXT, bookDescription TEXT, language TEXT, pagesCount INTEGER, cost DOUBLE, publishedDate TEXT, stockAvailable INTEGER, CONSTRAINT foreign_key1 FOREIGN KEY(genre) REFERENCES Genres(genre) ON UPDATE CASCADE ON DELETE CASCADE);"
    }
     
    func createInsertStatement(withData book: Book) -> String{
        let publishedDate: NSString = DateUtils.convertDateToString(input: book.publishedDate, pattern: .dateMonthYear) as NSString
        
        return "INSERT INTO LibraryBooks(id, title, author, genre, bookDescription, language, pagesCount, cost, publishedDate, stockAvailable) VALUES ('\(book.id)', '\(book.title)', '\(book.author)', '\(book.genre)', '\(book.bookDescription)', '\(book.language)', '\(book.pagesCount)', '\(book.cost)', '\(publishedDate)', '\(book.stockAvailable)');"
    }
    
    
    func createUpdateStatement(withData book: Book) -> String{
        let formattedPublishedDate = DateUtils.convertDateToString(input: book.publishedDate, pattern: .dateMonthYear)
        
        return "UPDATE LibraryBooks SET title = '\(book.title)', author = '\(book.author)', genre = '\(book.genre)', bookDescription = '\(book.bookDescription)', language = '\(book.language)', pagesCount = '\(book.pagesCount)', cost = '\(book.cost)', publishedDate = '\(formattedPublishedDate)', stockAvailable = '\(book.stockAvailable)' where id = '\(book.id)';"
    }
    
    func createDeleteStatement(withData bookId: String) -> String{
        "DELETE FROM LibraryBooks WHERE id = '\(bookId)';"
    }
    
    func fetchBooksCount() -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT COUNT(1) FROM LibraryBooks"
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK, executionResult == SQLITE_ROW{
            let count = Int(sqlite3_column_int(statement, 0))
            return .success(count)
        }
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
    
    func fetchBookDetails(booksFolderPath: URL?) -> Result<[Book], SQLiteError>{
        do{
            var queryStatement: OpaquePointer?
            defer { sqlite3_finalize(queryStatement) }
            
            var list: [Book] = []
            let queryStatementString = "SELECT * FROM LibraryBooks;"
            let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
            
            if queryPreparationResult == SQLITE_OK{
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    
                    let result1 = sqlite3_column_text(queryStatement, 0)!
                    let id = String(cString: result1)
                    
                    let result2 = sqlite3_column_text(queryStatement, 1)!
                    let title = String(cString: result2)
                    
                    let result3 = sqlite3_column_text(queryStatement, 2)!
                    let author = String(cString: result3)
                    
                    let result4 = sqlite3_column_text(queryStatement, 3)!
                    let genre = String(cString: result4)
                    
                    let result5 = sqlite3_column_text(queryStatement, 4)!
                    let bookDescription = String(cString: result5)
                    
                    let result6 = sqlite3_column_text(queryStatement, 5)!
                    let language = String(cString: result6)
                    
                    let result7 = sqlite3_column_int(queryStatement, 6)
                    let pagesCount = Int(result7)
                    
                    let result8 = sqlite3_column_double(queryStatement, 7)
                    let cost = Double(result8)
                    
                    let result9 = sqlite3_column_text(queryStatement, 8)!
                    let publishedDate = DateUtils.convertStringToDate(input: String(cString: result9), pattern: .dateMonthYear)
                    
                    let result10 = sqlite3_column_int(queryStatement, 9)
                    let stockAvailable = Int(result10)
                    
                    let filePath: String? = booksFolderPath?.appending(components: id).path
                    let bookImage: UIImage? = try ImagesFolderManager.getSavedImage(fromFilePath: filePath)
                    
                    let bookReviews = try dataProvider.getReviews(of: id)
                    
                    let book = Book(id: id, bookImage: bookImage, title: title, author: author, genre: genre, bookDescription: bookDescription, language: language, pagesCount: pagesCount, cost: cost, publishedDate: publishedDate, stockAvailable: stockAvailable, bookReviews: bookReviews)
                    
                    list.append(book)
                }
                return .success(list)
            }
            let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
            return .failure(sqliteError)
        }
        catch{
            return .failure(SQLiteError.generic)
        }
    }
    
    
}
 
 
