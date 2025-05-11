
import Foundation

struct ConcurrentQueue{
    
    static var dbQueue: DispatchQueue = {
        DispatchQueue(label: "DBOperations.concurrent.queue", qos: .background, attributes: .concurrent)
    }()
    
}























// Combine example prg

//func with<T: AnyObject>(_ object: T, action: (T) -> Void) {
//    action(object)
//}
//import Combine
//public struct ConcurrentQueue{
//
//    private var store = Set<AnyCancellable>()
//
//    public static var dbQueue: DispatchQueue = {
//        let queue = DispatchQueue(label: "DBOperations.concurrent.queue", qos: .background, attributes: .concurrent)
//        let queue = DispatchQueue(label: "DBOperations.serial.queue", qos: .background)
//        return queue
//    }()
//
//    mutating func test() {
//        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
//            .receive(on: DispatchQueue.main)
//            .sink { notification in
//                print(notification)
//            }
//            .store(in: &store)
//
//        let datamanager = DataManager()
//        datamanager.getUsers()
//            .receive(on: DispatchQueue.main)
//            .map { users in
//                users.map { $0.capitalized }
//            }
//            .sink { users in
//                print(users)
//            }
//            .store(in: &store)
//
//        store.first?.cancel()
//
//    }
//}
//
//
//class DataManager {
//    func getUsers() -> AnyPublisher<[String], Never> {
//        //background thread
//        return Just(["user 1", "user 2"]).eraseToAnyPublisher()
//    }
//}
