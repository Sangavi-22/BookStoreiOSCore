import Foundation

public class RegisteredNotification{
    
    public let notificationIdentifier: String
    public let bookId: String
    public let dateGenerated: Date
    public let targetedUser: Role
    
    public private(set) var status: NotificationStatus
    
    public init(notificationIdentifier: String, bookId: String, dateGenerated: Date, targetedUser: Role, status: NotificationStatus) {
        self.notificationIdentifier = notificationIdentifier
        self.bookId = bookId
        self.dateGenerated = dateGenerated
        self.targetedUser = targetedUser
        self.status = status
    }
    
    public func updateStatus(with status: NotificationStatus){
        self.status = status
    }
}

