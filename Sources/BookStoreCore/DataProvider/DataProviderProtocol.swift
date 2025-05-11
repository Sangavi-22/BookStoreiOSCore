import Foundation

public protocol DataProviderProtocol: AnyObject{
    
    func add(account: Account) throws

    func saveProfilePic(of account: Account) throws
    
    func updateAccount(to account: Account) throws
    
    func updateProfilePic(of account: Account) throws
    
    func remove(account: Account) throws
    
    func removeProfilePic(of account: Account) throws
    
    func getUserAccount(withEmailId emailId: String) throws -> Account?
    
    func getUserAccount(withUserId userId: String) throws -> Account
    
    func getAllAccounts() throws -> [Account]
    
    func getAccountsCount() throws -> Int
    
    func getMemberAccount(withUserId userId: String) throws -> MemberAccount
    
    func insert(borrowedCount: Int, ofUserId userId: String) throws
    
    func update(borrowedCount: Int, ofUserId userId: String) throws
    
    func getBorrowedCount(ofUserId userId: String) throws -> Int
    
    func addToWishList(book: Book, userId: String) throws
    
    func removeFromWishList(book: Book, userId: String) throws
    
    func getWishList(ofUserId userId: String) throws -> [String]
    
    func insert(order: BookOrder) throws
    
    func update(order: BookOrder)  throws
    
    func getOrdersPlaced(by userId: String) throws -> [BookOrder]
    
    func getAllOrders() throws -> [BookOrder]
    
    func getOrdersCount() throws -> Int
    
    func add(newGenre: String) throws
    
    func update(genre: String, to updatedName: String) throws
    
    func remove(genre: String) throws
    
    func getAllGenres() throws -> [String]
    
    func add(book: Book) throws
    
    func saveImage(of book: Book) throws
    
    func update(book: Book) throws
    
    func updateImage(of book: Book) throws
    
    func removeBook(of bookId: String) throws
    
    func getAllBooks() throws -> [Book]
    
    func getBooksCount() throws -> Int
    
    func insert(review: Review) throws
    
    func update(review: Review) throws
    
    func remove(review: Review) throws
    
    func getReviews(of bookId: String) throws -> [Review]
    
    func getAllReviews() throws -> [Review]
    
    func getReviewsCount() throws -> Int
    
    func add(notification: RegisteredNotification) throws
    
    func update(notification: RegisteredNotification) throws
    
    func getAllNotifications() throws -> [RegisteredNotification]
    
    func getNotificationsCount() throws -> Int
    
}

