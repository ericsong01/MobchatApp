import UIKit

struct User {
    
    var uid: String
    var username: String?
    var profileImageUrl: String?
    var bio: String?
    
    init(uid: String, dictionary: [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.uid = uid
    }
    
}
