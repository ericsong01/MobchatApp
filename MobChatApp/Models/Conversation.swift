import UIKit

class Conversation: NSObject {
    
    var imageUrl: String?
    var conversationName: String?
    var lastMessageTime: NSNumber?
    var conversationId: String?
    var chatDescription: String?
    var creatorId: String?
    var chatTimestamp: NSNumber?
    var chatIntroDescription: String?
    var numberOfMembersOnline: Int?
    var numberOfMembers: Int?
    
    init(dictionary: [String:AnyObject]) {
        
        conversationId = dictionary["conversationId"] as? String
        imageUrl = dictionary["conversationImageUrl"] as? String
        conversationName = dictionary["conversationName"] as? String
        lastMessageTime = dictionary["lastMessageTime"] as? NSNumber
        chatDescription = dictionary["description"] as? String
        chatTimestamp = dictionary["chatTimestamp"] as? NSNumber
        creatorId = dictionary["creatorId"] as? String
        chatIntroDescription = dictionary["chatIntroDescription"] as? String

    }
    
}
