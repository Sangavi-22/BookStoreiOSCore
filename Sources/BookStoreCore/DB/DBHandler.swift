

import Foundation

class DBHandler: DataProviderProtocol{
    
    var db: OpaquePointer?
    
    private var booksFolderPath: URL?
    private var profilePicFolderPath: URL?
    
    private lazy var dbHelper = DBHelper()
    private lazy var accountsDataTable = AccountsDataTableHelper(db: db)
    private lazy var wishListDataTable = WishListDataTableHelper(db: db)
    private lazy var activeTransactionsDataTable = BorrowedCountDataTableHelper(db: db)
    private lazy var genresDataTable = GenresDataTableHelper(db: db)
    private lazy var booksDataTable = BooksDataTableHelper(db: db)
    private lazy var reviewsDataTable = BookReviewsDataTableHelper(db: db)
    private lazy var ordersDataTable = OrdersDataTableHelper(db: db)
    private lazy var notificationsDataTable = NotificationsDataTableHelper(db: db)
    
    init(){
        setUp()
    }
    
    deinit{
        print("DBHandler is being deinitialized")
    }
    
    private func setUp(){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            dbHelper.openDatabase{ pointer in
                self.db = pointer
            }
            createTables()
            createFoldersToStoreImages()
        }
    }
    
    private func getCreateTableStatements() -> [String]{
        let createAccountsDataTable = accountsDataTable.getCreateStatementString()
        let createWishListTable = wishListDataTable.getCreateStatementString()
        let createTransactionsTable = activeTransactionsDataTable.getCreateStatementString()
        let createGenresTable = genresDataTable.getCreateStatementString()
        let createBooksTable = booksDataTable.getCreateStatementString()
        let createReviewsTable = reviewsDataTable.getCreateStatementString()
        let createOrdersTable = ordersDataTable.getCreateStatementString()
        let createNotificationsTable = notificationsDataTable.getCreateStatementString()
        
        return [createAccountsDataTable, createWishListTable, createTransactionsTable,
                createGenresTable, createBooksTable, createReviewsTable,
                createOrdersTable, createNotificationsTable]
    }
    
    private func createTables(){
        let createTableStatements = getCreateTableStatements()
        
        createTableStatements.forEach{ statement in
            let result = dbHelper.performOperationOnTable(with: statement)
            switch result{
            case .success(_):
                print("Table creation successfull")
                
            case .failure(let error):
                print("Table creation failed due to \(error)")
            }
        }
    }
    
    private func createFoldersToStoreImages(){
        do{
            try ConcurrentQueue.dbQueue.sync{
                booksFolderPath = try ImagesFolderManager.createFolder(withPathCompenent: "BookImagesFolder")
                profilePicFolderPath = try ImagesFolderManager.createFolder(withPathCompenent: "ProfilePictureFolder")
            }
        }
        catch{
            print("Folder creation failed")
        }
    }
    
    private func createFilePath(withFileName fileName: String, for folderContents: ContentsOfFolder) -> String?{
        switch folderContents{
        case .profilePic:
            return profilePicFolderPath?.appending(components: fileName).path
            
        case .bookImages:
            return booksFolderPath?.appending(components: fileName).path
        }
    }
    
    func add(account: Account) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            let queryForInserting = accountsDataTable.createInsertStatement(withData: account)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of account with userId = \(account.userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of account with userId = \(account.userId) performed successfully")
            }
        }
    }

    func saveProfilePic(of account: Account) throws{
        try ConcurrentQueue.dbQueue.sync {
            if let profilePicture: Data = account.profilePicture?.pngData(){
                let filePath = createFilePath(withFileName: account.emailId, for: .profilePic)
                try ImagesFolderManager.saveImage(atPath: filePath, contents: profilePicture)
            }
        }
    }
    
    func updateAccount(to account: Account) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            let queryForUpdating = accountsDataTable.createUpdateStatement(withData: account)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of account with userId = \(account.userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of account with userId = \(account.userId) performed successfully")
            }
        }
    }
    
    func updateProfilePic(of account: Account) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            let filePath = createFilePath(withFileName: account.emailId, for: .profilePic)
            if let profilePicture: Data = account.profilePicture?.pngData(){
                try ImagesFolderManager.saveImage(atPath: filePath, contents: profilePicture)
            }
        }
    }
    
    func remove(account: Account) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            let queryForRemoving = accountsDataTable.createDeleteStatement(withData: account)
            let result = dbHelper.performOperationOnTable(with: queryForRemoving)
            
            switch result{
            case .failure(let error):
                let message = "Deletion of account with userId = \(account.userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .deletion)
                
            case .success(_):
                print("Deletion of account with userId = \(account.userId) performed successfully")
            }
        }
    }
    
    func removeProfilePic(of account: Account) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            let filePath = createFilePath(withFileName: account.emailId, for: .profilePic)
            try ImagesFolderManager.deleteImage(atPath: filePath)
        }
    }
    
    func getUserAccount(withEmailId emailId: String) throws -> Account? {
        try getAllAccounts().first(where: {$0.emailId == emailId})
    }
    
    func getUserAccount(withUserId userId: String) throws -> Account{
        var result: Result<Account, SQLiteError>?
        fetchUserAccount(withUserId: userId){ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(reason: "Failed to obtain result from db", actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of user account failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let accountRetreived):
            return accountRetreived
        }
    }
    
    private func fetchUserAccount(withUserId userId: String, completionHandler: @escaping (Result<Account, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = accountsDataTable.fetchAccount(withUserId: userId, profilePicFolderPath: profilePicFolderPath)
            completionHandler(result)
        }
    }
    
    func getAllAccounts() throws -> [Account]{
        var result: Result<[Account], SQLiteError>?
        fetchAllAccounts{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of all account details failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let accountsRetreived):
            return accountsRetreived
        }
    }
    
    private func fetchAllAccounts(completionHandler: @escaping (Result<[Account], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = accountsDataTable.fetchAccountDetails(profilePicFolderPath: profilePicFolderPath)
            completionHandler(result)
        }
    }
    
    func getAccountsCount() throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchAccountsCount{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(reason: "Failed to obtain result from db", actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of accounts count failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let accountsCount):
            return accountsCount
        }
    }
    
    private func fetchAccountsCount(completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = accountsDataTable.fetchAccountsCount()
            completionHandler(result)
        }
    }
    
    func getMemberAccount(withUserId userId: String) throws -> MemberAccount{
        let account = try getUserAccount(withUserId: userId)
        let borrowedCount = try getBorrowedCount(ofUserId: userId)
        let orders = try getOrdersPlaced(by: userId).filter({$0.transactionStatus != .cancelledTransaction})
        let wishList = try getWishList(ofUserId: userId)
        
        return MemberAccount(userId: account.userId, role: account.role, emailId: account.emailId, password: account.password, name: account.name, mobileNum: account.mobileNum, address: account.address, profilePicture: account.profilePicture, borrowedCount: borrowedCount, listOfOrdersPlaced: orders, wishList: wishList)
    }
    
    func insert(borrowedCount: Int, ofUserId userId: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForInserting = activeTransactionsDataTable.createInsertStatement(with: borrowedCount, for: userId)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of borrowed count for account with userId = \(userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of borrowed count for account with userId = \(userId) performed successfully")
            }
        }
    }
    
    
    func update(borrowedCount: Int, ofUserId userId: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForUpdating = activeTransactionsDataTable.createUpdateStatement(with: borrowedCount, for: userId)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of borrowed count for account with userId = \(userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of borrowed count for account with userId = \(userId) performed successfully")
            }
        }
    }
    
    func getBorrowedCount(ofUserId userId: String) throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchBorrowedCount(ofUserId: userId){ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(reason: "Failed to obtain result from db", actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of borrowed count of userId = \(userId) failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let borrowedCount):
            return borrowedCount
        }
    }
    
    private func fetchBorrowedCount(ofUserId userId: String, completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = activeTransactionsDataTable.fetchBorrowedCount(of: userId)
            completionHandler(result)
        }
    }
    
    func addToWishList(book: Book, userId: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForInserting = wishListDataTable.createInsertStatement(with: book.id, for: userId)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of book to wishList of account with userId = \(userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of book to wishList of account with userId = \(userId) performed successfully")
            }
        }
    }
    
    func removeFromWishList(book: Book, userId: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForRemoving = wishListDataTable.createDeleteStatement(with: book.id, for: userId)
            let result = dbHelper.performOperationOnTable(with: queryForRemoving)
            
            switch result{
            case .failure(let error):
                let message = "Removal of book from wishList of account with userId = \(userId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .deletion)
                
            case .success(_):
                print("Removal of book from wishList of account with userId = \(userId) performed successfully")
            }
        }
    }
    
    func getWishList(ofUserId userId: String) throws -> [String]{
        var result: Result<[String], SQLiteError>?
        fetchWishList(ofUserId: userId){ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of wishList of userId = \(userId) failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let wishList):
            return wishList
        }
    }
    
    private func fetchWishList(ofUserId userId: String, completionHandler: @escaping (Result<[String], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = wishListDataTable.fetchWishListedBooks(for: userId)
            completionHandler(result)
        }
    }
    
    func insert(order: BookOrder) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForInserting = ordersDataTable.createInsertStatement(with: order)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of order with orderId = \(order.orderId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of order with orderId = \(order.orderId) performed successfully")
            }
        }
    }
    
    func update(order: BookOrder)  throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForUpdating = ordersDataTable.createUpdateStatement(with: order)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of order with orderId = \(order.orderId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of order with orderId = \(order.orderId) performed successfully")
            }
        }
    }
    
    func getOrdersPlaced(by userId: String) throws -> [BookOrder]{
        try getAllOrders().filter({$0.userId == userId && $0.transactionStatus != .cancelledTransaction})
    }
    
    func getAllOrders() throws -> [BookOrder]{
        var result: Result<[BookOrder], SQLiteError>?
        fetchAllOrders{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of all orders details failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let ordersPlaced):
            return ordersPlaced
        }
    }
    
    private func fetchAllOrders(completionHandler: @escaping (Result<[BookOrder], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = ordersDataTable.fetchOrderDetails()
            completionHandler(result)
        }
    }
    
    func getOrdersCount() throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchOrdersCount{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of total number of orders count failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let ordersCount):
            return ordersCount
        }
    }
    
    private func fetchOrdersCount(completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = ordersDataTable.fetchOrdersCount()
            completionHandler(result)
        }
    }
    
    func add(newGenre: String) throws {
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let genres = try getAllGenres()
            if !(genres.description.localizedCaseInsensitiveContains(newGenre)){
                let insertQuery = genresDataTable.createInsertStatement(withData: newGenre)
                let result = dbHelper.performOperationOnTable(with: insertQuery)
                
                switch result{
                case .failure(let error):
                    let message = "Insertion of \(newGenre) genre failed due to \(error)"
                    throw BookStoreCore.BookStoreError(
                        reason: message,
                        actionPerformed: .insertion)
                    
                case .success(_):
                    print("Insertion of \(newGenre) genre performed successfully")
                }
            }
        }
    }
    
    func update(genre: String, to updatedName: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let updateQuery = genresDataTable.createUpdateStatement(withPreviousName: genre, newName: updatedName)
            let result = dbHelper.performOperationOnTable(with: updateQuery)
            
            switch result{
            case .failure(let error):
                let message = "Updation of \(genre) genre failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of \(genre) genre performed successfully")
            }
        }
    }
    
    func remove(genre: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let deleteStatementString = genresDataTable.createDeleteStatement(withData: genre)
            let result = dbHelper.performOperationOnTable(with: deleteStatementString)
            
            switch result{
            case .failure(let error):
                let message = "Deletion of \(genre) genre failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .deletion)
                
            case .success(_):
                print("Deletion of \(genre) genre performed successfully")
            }
        }
    }
    
    func getAllGenres() throws -> [String]{
        var result: Result<[String], SQLiteError>?
        fetchAllGenres{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(reason: "Failed to obtain result from db", actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of all genres failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let genresRetreived):
            return genresRetreived
        }
    }
    
    private func fetchAllGenres(completionHandler: @escaping (Result<[String], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = genresDataTable.fetchAllGenres()
            completionHandler(result)
        }
    }
    
    func add(book: Book) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForInserting = booksDataTable.createInsertStatement(withData: book)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
        
            switch result{
            case .failure(let error):
                let message = "Insertion of book with bookId = \(book.id) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of book with bookId = \(book.id) performed successfully")
            }
        }
    }
    
    func saveImage(of book: Book) throws{
        try ConcurrentQueue.dbQueue.sync { [unowned self] in
            if let bookImage: Data = book.bookImage?.pngData(){
                let filePath = createFilePath(withFileName: book.id, for: .bookImages)
                try ImagesFolderManager.saveImage(atPath: filePath, contents: bookImage)
            }
        }
    }
    
    func update(book: Book) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForUpdating = booksDataTable.createUpdateStatement(withData: book)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of book with bookId = \(book.id) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of book with bookId = \(book.id) performed successfully")
            }
        }
    }
    
    func updateImage(of book: Book) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let filePath = createFilePath(withFileName: book.id, for: .bookImages)
            if let bookImage: Data = book.bookImage?.pngData(){
                try ImagesFolderManager.saveImage(atPath: filePath, contents: bookImage)
            }
        }
    }
    
    func removeBook(of bookId: String) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForRemoving = booksDataTable.createDeleteStatement(withData: bookId)
            let result = dbHelper.performOperationOnTable(with: queryForRemoving)
            
            switch result{
            case .failure(let error):
                let message = "Deletion of book with bookId = \(bookId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .deletion)
                
            case .success(_):
                print("Deletion of book with bookId = \(bookId) performed successfully")
            }
        }
    }
     
    func getAllBooks() throws -> [Book]{
        var result: Result<[Book], SQLiteError>?
        fetchAllBooks{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of all books failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let booksRetreived):
            return booksRetreived
        }
    }
    
    private func fetchAllBooks(completionHandler: @escaping (Result<[Book], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = booksDataTable.fetchBookDetails(booksFolderPath: booksFolderPath)
            completionHandler(result)
        }
    }
    
    func getBooksCount() throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchBooksCount{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of total number of books count failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let booksCount):
            return booksCount
        }
    }
    
    private func fetchBooksCount(completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = booksDataTable.fetchBooksCount()
            completionHandler(result)
        }
    }
    
    func insert(review: Review) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForInserting = reviewsDataTable.createInsertStatement(with: review)
            let result = dbHelper.performOperationOnTable(with: queryForInserting)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of review with reviewId = \(review.reviewId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
//                throw BookStoreCore.BSError(
//                    reason: message,
//                    operation: .create
//                )
                //DataValidationError.runTimeError(message)
                
            case .success(_):
                print("Insertion of review with reviewId = \(review.reviewId) performed successfully")
            }
        }
    }
    
    
    func update(review: Review) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForUpdating = reviewsDataTable.createUpdateStatement(with: review)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of review with reviewId = \(review.reviewId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of review with reviewId = \(review.reviewId) performed successfully")
            }
        }
    }
    
    func remove(review: Review) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForRemoving = reviewsDataTable.createDeleteStatement(with: review)
            let result = dbHelper.performOperationOnTable(with: queryForRemoving)
            
            switch result{
            case .failure(let error):
                let message = "Deletion of review with reviewId = \(review.reviewId) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .deletion)
                
            case .success(_):
                print("Deletion of review with reviewId = \(review.reviewId) performed successfully")
            }
        }
    }
    
    func getReviews(of bookId: String) throws -> [Review]{
        try getAllReviews().filter({$0.bookId == bookId})
    }
    
    func getAllReviews() throws -> [Review]{
        var result: Result<[Review], SQLiteError>?
        fetchAllReviews{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of book reviews failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let reviewsRetreived):
            return reviewsRetreived
        }
    }
    
    private func fetchAllReviews(completionHandler: @escaping (Result<[Review], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = reviewsDataTable.fetchReviews()
            completionHandler(result)
        }
    }
    
    func getReviewsCount() throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchReviewsCount{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of reviews count failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let reviewsCount):
            return reviewsCount
        }
    }
    
    private func fetchReviewsCount(completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = reviewsDataTable.fetchReviewsCount()
            completionHandler(result)
        }
    }
    
    
    func add(notification: RegisteredNotification) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let insertStatementString = notificationsDataTable.createInsertStatement(with: notification)
            let result = dbHelper.performOperationOnTable(with: insertStatementString)
            
            switch result{
            case .failure(let error):
                let message = "Insertion of notification with id = \(notification.notificationIdentifier) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .insertion)
                
            case .success(_):
                print("Insertion of notification with id = \(notification.notificationIdentifier) performed successfully")
            }
        }
    }
    
    func update(notification: RegisteredNotification) throws{
        try ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let queryForUpdating = notificationsDataTable.createUpdateStatement(withData: notification)
            let result = dbHelper.performOperationOnTable(with: queryForUpdating)
            
            switch result{
            case .failure(let error):
                let message = "Updation of notification with id = \(notification.notificationIdentifier) failed due to \(error)"
                throw BookStoreCore.BookStoreError(
                    reason: message,
                    actionPerformed: .updation)
                
            case .success(_):
                print("Updation of notification with id = \(notification.notificationIdentifier) performed successfully")
            }
        }
    }
    
    func getAllNotifications() throws -> [RegisteredNotification]{
        var result: Result<[RegisteredNotification], SQLiteError>?
        fetchAllNotifications{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of all notifications failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let notifications):
            return notifications
        }
    }
    
    private func fetchAllNotifications(completionHandler: @escaping (Result<[RegisteredNotification], SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync{ [unowned self] in
            let result = notificationsDataTable.fetchNotifications()
            completionHandler(result)
        }
    }
    
    func getNotificationsCount() throws -> Int{
        var result: Result<Int, SQLiteError>?
        fetchNotificationsCount{ resultObtained in
            result = resultObtained
        }
        
        guard let result else {
            throw BookStoreCore.BookStoreError(
                reason: "Failed to obtain result from db",
                actionPerformed: .fetching)
        }
        
        switch result{
        case .failure(let error):
            let message = "Fetching of notifications count failed due to \(error)"
            throw BookStoreCore.BookStoreError(
                reason: message,
                actionPerformed: .fetching)
            
        case .success(let notificationsCount):
            return notificationsCount
        }
    }
    
    private func fetchNotificationsCount(completionHandler: @escaping (Result<Int, SQLiteError>) -> Void){
        ConcurrentQueue.dbQueue.sync { [unowned self] in
            let result = notificationsDataTable.fetchNotificationsCount()
            completionHandler(result)
        }
    }
    
}
    
    

    

    

    
    
    

    

    

   
    
    

    
    
   

    

    

    
