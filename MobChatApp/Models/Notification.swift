import UIKit

class Notification: NSObject {
    
    var notificationDescription: String?
    var notificationTitle: String?
    var notificationDate: NSNumber?
    var notificationId: String?
    var opened = false  // For table view
    
    init(dictionary: [String:AnyObject]) {
        
        notificationDescription = dictionary["notificationDescription"] as? String
        notificationTitle = dictionary["notificationTitle"] as? String
        notificationDate = dictionary["notificationDate"] as? NSNumber
        notificationId = dictionary["notificationId"] as? String
        
    }
}
