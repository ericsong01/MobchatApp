import UIKit
import Firebase

var globalAnnouncement: String?

class AnnouncementsViewController: UIViewController {
    
    let announcementTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        navigationItem.title = "Announcements"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        view.addSubview(announcementTextView)
        announcementTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingBottom: 15, paddingRight: 20, width: 0, height: 0)
        
        if let announcement = globalAnnouncement {
            announcementTextView.text = announcement
        } else {
            fetchAnnouncement()
        }
        
    }
    
    fileprivate func fetchAnnouncement() {
        print ("fetching announcement")
        let ref = Database.database().reference()
        ref.child("announcement").observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {return}
            self.announcementTextView.text = dict["announcement"] as? String
            globalAnnouncement = dict["announcement"] as? String
        }
    }
    
    @objc func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
