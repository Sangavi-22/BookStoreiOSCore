
import Foundation

public struct DateUtils{
    
    private static let dateFormatter = DateFormatter()
    
    public static func filterAndGetDeliveryDate(from ordersList: [BookOrder]) -> Date{
        guard !(ordersList.isEmpty) else {
            return getDate(adding: 5, with: getCurrentDate())
        }
        
        let currentOrderedDate = Date()
        let previousDeliveryDate = getPreviousDeliveryDate(from: ordersList)
        let previousReturnDate = getPreviousReturnDate(from: ordersList)
        
        /* When the ordered date is lesser than the previous order's delivery date then the second order's delivery date would be the same as previous order
         If the ordered date is greater than previous order's delivery date then we can check with previous order's return date,
         If the books in previous order is already returned and the date has expired then the next order's delivery date would be five days after the date of order being placed */
        
        if currentOrderedDate < previousDeliveryDate{
            return previousDeliveryDate
        }
        else if currentOrderedDate > previousDeliveryDate &&
                    currentOrderedDate < previousReturnDate{
            return previousReturnDate
        }
        else {
            return getDate(adding: 5, with: getCurrentDate())
        }
    }
    
    public static func getDate(adding days: Int, with date: Date) -> Date{
        var dateComponent = DateComponents()
        dateComponent.day = days
        return Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
    }
    
    public static func getPreviousDeliveryDate(from orders: [BookOrder]) -> Date{
        let deliveryDates = orders.map { $0.bookDeliveryDate }
        return deliveryDates.max() ?? Date()
    }
    
    public static func getPreviousReturnDate(from orders: [BookOrder]) -> Date{
        let returnDates = orders.map { $0.bookReturnDate }
        return returnDates.max() ?? Date()
    }
    
    public static func checkDifferenceBetween(firstDate: Date, secondDate: Date) -> Int{
        let difference = Calendar.current.dateComponents([.day], from: firstDate, to: secondDate).day!
        return difference < 0 ? (difference * -1) : difference
    }
    
    public static func convertDateToString(input: Date, pattern: DatePattern) -> String{
        dateFormatter.dateFormat = pattern.rawValue
        return dateFormatter.string(from: input)
    }
    
    public static func convertStringToDate(input: String, pattern: DatePattern) -> Date{
        dateFormatter.dateFormat = pattern.rawValue
        return dateFormatter.date(from: input) ?? Date()
    }
    
    public static func dateExpired(_ date: Date) -> Bool{
        date <= getCurrentDate()
    }
    
    public static func getCurrentDate() -> Date{
        Date()
    }
    
    public static func getDiffBetweenCurrentDate(and date: Date) -> String{
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
           formatter.maximumUnitCount = 1
           formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]

           guard let relativeDate = formatter.string(from: date, to: getCurrentDate()) else {
               return "0 seconds ago"
           }

           return relativeDate + " ago"
    }
    
}




