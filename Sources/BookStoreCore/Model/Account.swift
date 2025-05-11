import UIKit

public class Account{
    
    public let userId: String
    public let role: Role
    
    public private(set) var emailId: String
    public private(set) var password: String
    public private(set) var name: String
    public private(set) var mobileNum: String
    public private(set) var address: String
    public private(set) var profilePicture: UIImage?
    
    public init(userId: String, role: Role, emailId: String, password: String, name: String, mobileNum: String, address: String, profilePicture: UIImage?) {
        self.userId = userId
        self.role = role
        self.emailId = emailId
        self.password = password
        self.name = name
        self.mobileNum = mobileNum
        self.address = address
        self.profilePicture = profilePicture
    }
    
    public func verification(of inputtedPassword: String) -> Bool{
        let hashedInputtedPassword = PasswordHasher.hash(userId: userId, password: inputtedPassword)
        return password == hashedInputtedPassword
    }
    
    public subscript<T>(keypath: ReferenceWritableKeyPath<Account, T>) -> T {
        get { self[keyPath: keypath] }
        set { self[keyPath: keypath] = newValue }
    }

    public subscript<T>(keypath: KeyPath<Account, T>) -> T {
        get { self[keyPath: keypath] }
        set {
            if let writableKeyPath = keypath as? ReferenceWritableKeyPath<Account, T> {
                self[keyPath: writableKeyPath] = newValue
            }
        }
    }

}

