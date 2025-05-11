import Foundation

public class BookOrder{
    
    public let orderId: String
    public let userId: String
    public let bookId: String
    
    public private(set) var bookDeliveryDate: Date
    public private(set) var bookReturnDate: Date
    public private(set) var transactionStatus: TransactionStatus
    
    public init(orderId: String, userId: String, bookId: String, bookDeliveryDate: Date, bookReturnDate: Date, transactionStatus: TransactionStatus) {
        self.orderId = orderId
        self.userId = userId
        self.bookId = bookId
        self.bookDeliveryDate = bookDeliveryDate
        self.bookReturnDate = bookReturnDate
        self.transactionStatus = transactionStatus
    }
    
    public subscript<T>(_ keypath: ReferenceWritableKeyPath<BookOrder, T>) -> T{
        get { self[keyPath: keypath] }
        set { self[keyPath: keypath] = newValue }
    }
    
    public subscript<T>(_ keypath: KeyPath<BookOrder, T>) -> T{
        get { self[keyPath: keypath] }
        set {
            if let writableKeyPath = keypath as? ReferenceWritableKeyPath<BookOrder, T> {
                self[keyPath: writableKeyPath] = newValue
            }
        }
    }
    
}
 


