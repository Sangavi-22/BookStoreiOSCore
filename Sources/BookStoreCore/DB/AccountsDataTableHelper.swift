
import Foundation
import SQLite3
import UIKit

class AccountsDataTableHelper{
    
    private var db: OpaquePointer?
    
    init(db: OpaquePointer? = nil) {
        self.db = db
    }
    
    func getCreateStatementString() -> String{
        "CREATE TABLE if not exists AccountDetails(userId TEXT PRIMARY KEY, emailId TEXT, password TEXT, name TEXT, mobileNum TEXT, address TEXT, role TEXT);"
    }
    
    func createInsertStatement(withData account: Account) -> String{
        "INSERT INTO AccountDetails(userId, emailId, password, name, mobileNum, address, role) VALUES ('\(account.userId)', '\(account.emailId)', '\(account.password)', '\(account.name)', '\(account.mobileNum)', '\(account.address)', '\(account.role)');"
    }
    
    func createUpdateStatement(withData account: Account) -> String{
        "UPDATE AccountDetails SET emailId = '\(account.emailId)', password = '\(account.password)', name = '\(account.name)', mobileNum = '\(account.mobileNum)', address = '\(account.address)', role = '\(account.role)' where userId = '\(account.userId)';"
    }
    
    func createDeleteStatement(withData account: Account) -> String{
        "DELETE FROM AccountDetails WHERE userId = '\(account.userId)';"
    }
    
    func fetchAccountsCount() -> Result<Int, SQLiteError>{
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        let query = "SELECT COUNT(1) FROM AccountDetails"
        let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        let executionResult = sqlite3_step(statement)
        
        if queryPreparationResult == SQLITE_OK, executionResult == SQLITE_ROW{
            let count = Int(sqlite3_column_int(statement, 0))
            return .success(count)
        }
        
        let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
        return .failure(sqliteError)
    }
    
    func fetchAccount(withUserId userId: String, profilePicFolderPath: URL?) -> Result<Account, SQLiteError>{
        do{
            var statement: OpaquePointer?
            defer{ sqlite3_finalize(statement) }
        
            let query = "SELECT * FROM AccountDetails WHERE userId = \(userId)"
            let queryPreparationResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
            let executionResult = sqlite3_step(statement)
            
            guard queryPreparationResult == SQLITE_OK, executionResult == SQLITE_ROW else {
                let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
                return .failure(sqliteError)
            }
            
            let result1 = sqlite3_column_text(statement, 0)!
            let userId = String(cString: result1)
            
            let result2 = sqlite3_column_text(statement, 1)!
            let emailId = String(cString: result2)
            
            let result3 = sqlite3_column_text(statement, 2)!
            let password = String(cString: result3)
            
            let result4 = sqlite3_column_text(statement, 3)!
            let name = String(cString: result4)
            
            let result5 = sqlite3_column_text(statement, 4)!
            let mobileNum = String(cString: result5)
            
            let result6 = sqlite3_column_text(statement, 5)!
            let address = String(cString: result6)
            
            let result7 = sqlite3_column_text(statement, 6)!
            let role = Role(rawValue: String(cString: result7))!
            
            let filePath: String? = profilePicFolderPath?.appending(components: emailId).path
            let profilePicture: UIImage? = try ImagesFolderManager.getSavedImage(fromFilePath: filePath)
            
            let account = Account(userId: userId, role: role, emailId: emailId, password: password, name: name, mobileNum: mobileNum, address: address, profilePicture: profilePicture)
            
            return .success(account)
        }
        catch{
            return .failure(.generic)
        }
    }
    
    func fetchAccountDetails(profilePicFolderPath: URL?) -> Result<[Account], SQLiteError>{
        do{
            var queryStatement: OpaquePointer?
            defer { sqlite3_finalize(queryStatement) }

            var list: [Account] = []
            let queryStatementString = "SELECT * FROM AccountDetails;"
            let queryPreparationResult = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
            
            if queryPreparationResult == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    
                    let result1 = sqlite3_column_text(queryStatement, 0)!
                    let userId = String(cString: result1)
                    
                    let result2 = sqlite3_column_text(queryStatement, 1)!
                    let emailId = String(cString: result2)
                    
                    let result3 = sqlite3_column_text(queryStatement, 2)!
                    let password = String(cString: result3)
                    
                    let result4 = sqlite3_column_text(queryStatement, 3)!
                    let name = String(cString: result4)
                    
                    let result5 = sqlite3_column_text(queryStatement, 4)!
                    let mobileNum = String(cString: result5)
                    
                    let result6 = sqlite3_column_text(queryStatement, 5)!
                    let address = String(cString: result6)
                    
                    let result7 = sqlite3_column_text(queryStatement, 6)!
                    let role = Role(rawValue: String(cString: result7))!
                    
                    let filePath: String? = profilePicFolderPath?.appending(components: emailId).path
                    let profilePicture: UIImage? = try ImagesFolderManager.getSavedImage(fromFilePath: filePath)
                    
                    let account = Account(userId: userId, role: role, emailId: emailId, password: password, name: name, mobileNum: mobileNum, address: address, profilePicture: profilePicture)
                    
                    list.append(account)
                }
                return .success(list)
            }
            
            let sqliteError = SQLiteError(errorCode: queryPreparationResult)!
            return .failure(sqliteError)
        }
        catch{
            return .failure(.generic)
        }
    }
}



