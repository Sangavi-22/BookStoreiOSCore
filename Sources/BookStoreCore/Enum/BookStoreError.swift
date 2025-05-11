public extension BookStoreCore{
    struct BookStoreError: Error{
        public let reason: String
        public let actionPerformed: CRUDAction
    }
}







//public enum DataValidationError: Error{
//    case runTimeError(String)
//}
//
//public extension BookStoreCore {
//    struct BSError: Error {
//        let reason: String
//        let operation: CURD
//    }
//
//    enum CURD {
//        case create
//        case update
//        case read
//        case delete
//    }
////}

