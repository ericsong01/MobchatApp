import UIKit

class Message {

    var senderId: String?
    var text: String?
    var timestamp: Date
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl: String?
    var messageId: String?
    
    init(dictionary: [String:AnyObject]) {
        
        senderId = dictionary["senderId"] as? String
        text = dictionary["text"] as? String
        let secondsFrom1970 = dictionary["timestamp"] as? Double ?? 0
        timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
        messageId = dictionary["messageId"] as? String
    }
    
}
