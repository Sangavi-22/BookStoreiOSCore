import SQLite3

enum SQLiteError: String, Error{
    case generic
    case internalLogic
    case permissionDenied
    case dbabort
    case dbbusy
    case dbislocked
    case readonlyDB
    case interrupt
    case io
    case dbcorrupted
    case dbFull
    case cantOpenDBFile
    case schemaChanged
    case dataTypeMismatch
    case authorizationDenied
    case dataSizeExceedsLimit
    
    init?(errorCode: Int32) {
        switch errorCode{
        case SQLITE_INTERNAL:
            self = .internalLogic
            
        case SQLITE_PERM:
            self = .permissionDenied
            
        case SQLITE_ABORT:
            self = .dbabort
            
        case SQLITE_BUSY:
            self = .dbbusy
            
        case SQLITE_LOCKED:
            self = .dbislocked
            
        case SQLITE_READONLY:
            self = .readonlyDB
            
        case SQLITE_INTERRUPT:
            self = .interrupt
            
        case SQLITE_IOERR:
            self = .io
            
        case SQLITE_CORRUPT:
            self = .dbcorrupted
            
        case SQLITE_FULL:
            self = .dbFull
            
        case SQLITE_CANTOPEN:
            self = .cantOpenDBFile
            
        case SQLITE_SCHEMA:
            self = .schemaChanged
            
        case SQLITE_MISMATCH:
            self = .dataTypeMismatch
            
        case SQLITE_AUTH:
            self = .authorizationDenied
            
        case SQLITE_TOOBIG:
            self = .dataSizeExceedsLimit
            
        default:
            self = .generic
        }
    }
}
