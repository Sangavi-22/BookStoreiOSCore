import Foundation

public class Library{
    
    public private(set) var libraryBooks: [Book] = []
    public private(set) var genres: [String] = []
    
    public static let shared = Library()
    
    private init(){
        //private constructor
    }
    
    public func loadData(books: [Book], genres: [String]){
        self.libraryBooks = books
        self.genres = genres
    }

    public func add(_ book: Book){
        libraryBooks.append(book)
    }
    
    public func update(at position: Int, with book: Book){
        libraryBooks[position] = book
    }
    
    public func removeBook(at position: Int){
        libraryBooks.remove(at: position)
    }
    
    public func add(_ newGenre: String){
        genres.append(newGenre)
    }
    
    public func updateGenre(at position: Int, to updatedName: String){
        genres[position] = updatedName
    }
    
    public func removeGenre(at position: Int){
        genres.remove(at: position)
    }
    
}


