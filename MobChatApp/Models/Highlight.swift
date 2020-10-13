import UIKit

struct Highlight {
    
    var senderId: String?
    var thumbnailImageUrl: String?
    var timestamp: NSNumber?
    var title: String?
    var videoUrl: String?
    var highlightId: String?
    
    init(dictionary: [String:AnyObject]) {
        
        senderId = dictionary["senderId"] as? String
        thumbnailImageUrl = dictionary["thumbnailImageUrl"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        title = dictionary["title"] as? String
        videoUrl = dictionary["videoUrl"] as? String
        highlightId = dictionary["highlightId"] as? String

    }
    
}
