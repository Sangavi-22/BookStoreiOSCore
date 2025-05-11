import UIKit
public class MemberAccount: Account{
    
    public let maxTransactionLimit = 5
    
    public private(set) var borrowedCount: Int
    public private(set) var listOfOrdersPlaced: [BookOrder]
    public private(set) var wishList: [String]
    
    public init(userId: String, role: Role, emailId: String, password: String, name: String, mobileNum: String, address: String, profilePicture: UIImage?, borrowedCount: Int, listOfOrdersPlaced: [BookOrder], wishList: [String]) {
        self.borrowedCount = borrowedCount
        self.listOfOrdersPlaced = listOfOrdersPlaced
        self.wishList = wishList
        
        super.init(userId: userId, role: role, emailId: emailId, password: password, name: name, mobileNum: mobileNum, address: address, profilePicture: profilePicture)
    }
    
    public func addToWishList(_ book: Book){
        wishList.append(book.id)
    }
    
    public func removeBookFromWishList(at position: Int){
        wishList.remove(at: position)
    }
    
    public func addToOrdersList(_ order: BookOrder){
        listOfOrdersPlaced.append(order)
    }
    
    public func update(_ order: BookOrder){
        _ = listOfOrdersPlaced.map({$0.orderId == order.orderId})
    }
    
    public func removeFromOrdersList(at position: Int){
        listOfOrdersPlaced.remove(at: position)
    }
    
    public func updateBorrowedCount(to count: Int){
        self.borrowedCount = count
    }

}

