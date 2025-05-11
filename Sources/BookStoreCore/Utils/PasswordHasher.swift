
import CryptoKit
import Foundation

public struct PasswordHasher{
    
    public static func hash(userId: String, password: String) -> String{
        let stringToHash = "\(userId).\(password)"
        
        let dataInput = Data(stringToHash.utf8)
        let hashed = SHA256.hash(data: dataInput)
        
        let hashedString = hashed.compactMap { String(format: "%02x", $0) } .joined()
        return hashedString
    }

}

