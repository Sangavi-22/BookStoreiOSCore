import Foundation
public class Review{
    
    public let reviewId: String
    public let userId: String
    public let bookId: String
    public let dateGenerated: Date
    
    public private(set) var title: String
    public private(set) var message: String
    public private(set) var rating: Int
    
    public init(reviewId: String, userId: String, bookId: String, dateGenerated: Date, title: String, message: String, rating: Int) {
        self.reviewId = reviewId
        self.userId = userId
        self.bookId = bookId
        self.dateGenerated = dateGenerated
        self.title = title
        self.message = message
        self.rating = rating
    }
    
    public subscript<T>(_ keypath: ReferenceWritableKeyPath<Review, T>) -> T{
        get { self[keyPath: keypath] }
        set { self[keyPath: keypath] = newValue }
    }
    
    public subscript<T>(_ keypath: KeyPath<Review, T>) -> T{
        get { self[keyPath: keypath] }
        set {
            if let writableKeyPath = keypath as? ReferenceWritableKeyPath<Review, T> {
                self[keyPath: writableKeyPath] = newValue
            }
        }
    }
    
}

