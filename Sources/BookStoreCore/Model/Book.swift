import Foundation
import UIKit
 
public class Book {
    
    public let id: String
    public private(set) var bookImage: UIImage?
    public private(set) var title: String
    public private(set) var author: String
    public private(set) var genre: String
    public private(set) var bookDescription: String
    public private(set) var language: String
    public private(set) var pagesCount: Int
    public private(set) var cost: Double
    public private(set) var publishedDate: Date
    public private(set) var stockAvailable: Int
    public private(set) var bookReviews: [Review]
    
    
    public init(id: String, bookImage: UIImage?, title: String, author: String, genre: String, bookDescription: String, language: String, pagesCount: Int, cost: Double, publishedDate: Date, stockAvailable: Int, bookReviews: [Review]) {
        self.id = id
        self.bookImage = bookImage
        self.title = title
        self.author = author
        self.genre = genre
        self.bookDescription = bookDescription
        self.language = language
        self.pagesCount = pagesCount
        self.cost = cost
        self.publishedDate = publishedDate
        self.stockAvailable = stockAvailable
        self.bookReviews = bookReviews
    }
    
    public func insert(_ review: Review){
        self.bookReviews.append(review)
    }
    
    public func update(_ review: Review){
        bookReviews = bookReviews.map {($0.reviewId == review.reviewId) ? review : $0}
    }
    
    public func removeReview(at position: Int){
        self.bookReviews.remove(at: position)
    }
    
    public subscript<T>(_ keypath: ReferenceWritableKeyPath<Book, T>) -> T{
        get { self[keyPath: keypath] }
        set { self[keyPath: keypath] = newValue }
    }
    
    public subscript<T>(_ keypath: KeyPath<Book, T>) -> T{
        get { self[keyPath: keypath] }
        set {
            if let writableKeyPath = keypath as? ReferenceWritableKeyPath<Book, T> {
                self[keyPath: writableKeyPath] = newValue
            }
        }
    }

}

