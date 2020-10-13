import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MobileCoreServices
import AVKit
import AVFoundation

var bannedConversations = [String]()

protocol PopChatLogControllerProtocol: class {
    func popChatLogController()
}

protocol PlayHighlightProtocol: class {
    func playHighlight(url: String)
    func deleteHighlight(videoTitle: String, highlightId: String)
}

protocol RefreshChatLogProtocol: class {
    func refreshChatLog()
}

var numberOfDeletes = 0

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, ChatInputAccessoryViewDelegate, ProfileImageProtocol, PopChatLogControllerProtocol, UIImagePickerControllerDelegate, PlayHighlightProtocol, UITableViewDataSource, UITableViewDelegate, RefreshChatLogProtocol {
    
    func refreshChatLog() {
        self.highlightLogs.removeAll()
        self.highlightsLogView.tableView.reloadData()
        retrieveHighlightsLog()
    }
    
    func popChatLogController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    var conversation: Conversation? {
        didSet {
            
            checkForCreator()
            
            checkIfUserIsBanned()
            
            navigationItem.title = conversation?.conversationName
            
            descriptionTestTextView.text = conversation?.chatIntroDescription
            
            self.conversationId = conversation?.conversationId
            
            paginateMessages()
        }
    }
    
    var firstTimeCheckDone = false
    
    fileprivate func checkIfUserIsBanned() {
        
        guard let conversationId = self.conversation?.conversationId, let uid = Auth.auth().currentUser?.uid, let myUsername = globalUsername else {return}
        
        var banVotesRequired = 3
        if self.isCreator ?? false {
            banVotesRequired = 5
        } else {
            banVotesRequired = 3
        }
        // Observe single event first, and then set firebase query for timestamp
        var timestamp: NSNumber?
        let ref = Database.database().reference().child("conversation_kickUser_votes").child(conversationId).child(uid)
        let initialQuery = ref.queryOrdered(byChild: "timestamp")
        initialQuery.queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
            
            // Find the timestamp for the ban observer
            guard var array = snapshot.children.allObjects as? [DataSnapshot] else {return}
            array.reverse()
            guard let value = array.first?.value as? [String:NSNumber] else {return}
            timestamp = value["timestamp"]
            
            if snapshot.childrenCount >= banVotesRequired {
                print ("user is banned")
                let bannedRef = Database.database().reference().child("conversations_bannedUsers").child(conversationId)
                bannedRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.exists() { // If the user has been checked for ban already and value is in
                        // Do nothing
                    } else {
                        
                        let ref = Database.database().reference()
                        
                        guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
                        let log = ["BanReceived":"\(myUsername) received their ban from this conversation \u{1F6AB}"]
                        let values = ["/conversations_bannedUsers/\(conversationId)/\(uid)":1, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
                        
                        ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print ("Couldn't update banned values:", error)
                            }
                        })
                    }
                    
                    bannedConversations.append(conversationId)
                    let alertController = UIAlertController(title: "You have been banned from this conversation", message: "You will be unbanned if you receive enough votes again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "\u{1F622}\u{1F622}\u{1F622}", style: .default, handler: { (_) in
                        
                        alertController.dismiss(animated: true, completion: nil)
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    })
                    
                    let checkForUnbanAction = UIAlertAction(title: "Check if I've been Unbanned", style: .default, handler: { (_) in
                        
                        Database.database().reference().child("conversations_bannedUsers").child(conversationId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if snapshot.childrenCount >= 3 {
                                
                                for (index, conversation) in bannedConversations.enumerated() {
                                    if conversation == conversationId { // Remove the conversation from global var bannedConversations
                                        bannedConversations.remove(at: index)
                                    }
                                }
                                
                                let ref = Database.database().reference()
                                
                                guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
                                let log = ["UnbanReceived": "\(myUsername) was unbanned"]
                                
                                let deleteValues = ["/conversation_kickUser_votes/\(conversationId)/\(uid)": NSNull(), "/conversations_bannedUsers/\(conversationId)/\(uid)":NSNull(), "/highlights_log/\(conversationId)/\(logKey)":log] as [String : AnyObject]
                                
                                ref.updateChildValues(deleteValues, withCompletionBlock: { (error, ref) in
                                    if let error = error {
                                        print ("Couldn't remove kick values for user unbanned:", error)
                                    }
                                    
                                    let alertController = UIAlertController(title: "You've been unbanned", message: "Congratulations! Don't screw it up this time", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "\u{1F603}", style: .default, handler: { (_) in
                                        alertController.dismiss(animated: true, completion: nil)
                                    }))
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                })
                                
                            } else {
                                let banAlertController = UIAlertController(title: "Nope, still banned", message: "", preferredStyle: .alert)
                                banAlertController.addAction(UIAlertAction(title: "\u{1F63F}", style: .default, handler: { (_) in
                                    banAlertController.dismiss(animated: true, completion: nil)
                                    self.navigationController?.popToRootViewController(animated: true)
                                }))
                                self.present(banAlertController, animated: true, completion: nil)
                            }
                        })
                        
                    })
                    alertController.addAction(okAction)
                    alertController.addAction(checkForUnbanAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                })
                
            }
            
        }
        
        // TODO: REVIEW THIS
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            initialQuery.queryStarting(atValue: timestamp).observe(.childAdded) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:NSNumber] else {return}
                if dictionary["timestamp"] == timestamp || snapshot.key.contains("creatorVote") {
                    return
                }

                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.childrenCount >= banVotesRequired {
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        let ref = Database.database().reference()
                        
                        guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
                        let log = ["BanReceived": "\(myUsername) received their ban from this conversation \u{1F6AB}"]
                        let values = ["/conversations_bannedUsers/\(conversationId)/\(uid)":1, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
                        
                        ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print ("Couldn't update banned values:", error)
                            }
                        })
                        
                        bannedConversations.append(conversationId)
                        let alertController = UIAlertController(title: "You have been banned from this conversation", message: "You will be unbanned if you receive enough votes again.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "\u{1F622}\u{1F622}\u{1F622}", style: .default, handler: { (_) in
                            
                            alertController.dismiss(animated: true, completion: nil)
                            self.dismiss(animated: true, completion: {
                                self.presentingViewController?.dismiss(animated: true, completion: nil)
                            })
                            self.navigationController?.popToRootViewController(animated: true)
                            
                        })
                        
                        alertController.addAction(okAction)
                        // Won't work if alert controllers are already presented
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                })
                
            }
        }
        
    }
    
    var conversationId: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add the active user to database
        let ref = Database.database().reference()
        if let conversationId = self.conversationId, let uid = Auth.auth().currentUser?.uid {
            let updateValues = ["/conversations_active_users/\(conversationId)/\(uid)":1]
            ref.updateChildValues(updateValues)
        }
        print ("viewDidAppear")
        if isMemberOfChat ?? false {
            reportChatButton.isEnabled = true
            eventsButton.isEnabled = true
            voteToBanButton.isEnabled = true
        } else {
            reportChatButton.isEnabled = false
            eventsButton.isEnabled = false
            voteToBanButton.isEnabled = false
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Delete the active user from database
        
        let ref = Database.database().reference()
        print ("viewDidDisappear")
        if let conversationId = self.conversationId, let uid = Auth.auth().currentUser?.uid {
            let updateValues = ["/conversations_active_users/\(conversationId)/\(uid)":NSNull()]
            ref.updateChildValues(updateValues)
        }
        
    }
    
    var isMemberOfChat: Bool?
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var isFinishedPaging = false
    
    var endingKey: String!
    
    func paginateMessages() {
        
        guard let convoId = self.conversationId else {return}
        
        let messagesRef = Database.database().reference().child("conversation_messages").child(convoId)
        var query = messagesRef.queryOrderedByKey()
        
        if messages.count > 0 {
            let value = endingKey as! String // We cast as string in order to avoid crash when user is not connected to internet
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                allObjects.reverse()
                
                self.endingKey = allObjects.last?.key
                
                if allObjects.count < 30 {
                    self.isFinishedPaging = true
                }
                
                if self.messages.count > 0 && allObjects.count > 0 {
                    allObjects.removeFirst()
                }
                
                for child in allObjects {
                    guard let dictionary = child.value as? [String:AnyObject] else {return}
                    // let messageKey = child.key
                    let message = Message(dictionary: dictionary as [String : AnyObject])
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }) { (error) in
            print ("Failed to load and paginate messages:", error)
        }
    }
    
    fileprivate func observeMessages() {
        guard let convoId = self.conversationId else {return}
        let messagesRef = Database.database().reference().child("conversation_messages").child(convoId)
        
        let query = messagesRef.queryOrdered(byChild: "timestamp")
        let now = NSDate().timeIntervalSince1970
        query.queryStarting(atValue: now).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
            let message = Message(dictionary: dictionary)
            self.messages.insert(message, at: 0)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: nil)
        }
        
    }
    
    func deleteVideoMessageForIndexPath(indexPath: IndexPath) {
        guard let convoId = self.conversationId else {return}

        guard let messageId = messages[indexPath.item].messageId else {return}
        
        mediaActivityIndicator.startAnimating()
        Database.database().reference().child("conversation_messages").child(convoId).child(messageId).removeValue { (error, ref) in
            
            if let error = error {
                print ("Error removing video msg from database:", error)
            }
            
            Storage.storage().reference().child("messages_imageThumbnails").child(convoId).child(messageId).delete(completion: { (error) in
                
                if let error = error {
                    print ("Error deleting video thumbnail:", error)
                }
                Storage.storage().reference().child("message_movies").child(convoId).child(messageId).delete(completion: { (error) in
                    if let error = error {
                        print ("Error deleting video:", error)
                    }
                    
                    self.messages.remove(at: indexPath.item)
                    self.collectionView.performBatchUpdates({
                        self.mediaActivityIndicator.stopAnimating()
                        self.collectionView.deleteItems(at: [indexPath])
                    }, completion: nil)
                    
                })
                
            })
            
        }
        
    }
    
    var fromSearchController: Bool?
    
    var collectionViewBottomAnchor: NSLayoutConstraint?
    
    let mediaActivityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.hidesWhenStopped = true
        aiv.color = UIColor.purple
        return aiv
    }()
    
    let videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        return view
    }()
    
    let highlightsLogView: HighlightsLogView = {
        let view = HighlightsLogView()
        return view
    }()
    
    var videoPlayerRightConstraint: NSLayoutConstraint?
    
    var highlights = [Highlight]()
    var highlightsDict = [String:Highlight]()
    
    // TODO: Take out the retrieveHighlights from the DispatchQueue.now + 1.0 block and test if it still lags, fix the .childRemoved part because that part actually needs the reloadHighlightsCollectionView() - check for repeating code statements
    func retrieveHighlights() {
        
        guard let conversationId = self.conversationId else {return}
        
        let ref = Database.database().reference().child("conversations_highlights").child(conversationId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
            let highlight = Highlight(dictionary: dictionary)
            
            self.highlightsDict[snapshot.key] = highlight
            
            self.highlights = Array(self.highlightsDict.values)
            
            self.highlights.sort { (h1, h2) -> Bool in
                return (h1.timestamp?.intValue)! > (h2.timestamp?.intValue)!
            }
            
            self.videoPlayerView.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in

            self.highlightsDict.removeValue(forKey: snapshot.key)

            self.reloadHighlightsCollectionView()

        }, withCancel: nil)
        
    }
    
    fileprivate func reloadHighlightsCollectionView() {
        self.highlights = Array(self.highlightsDict.values)
        
        self.highlights.sort { (h1, h2) -> Bool in
            return (h1.timestamp?.intValue)! > (h2.timestamp?.intValue)!
        }
        
        DispatchQueue.main.async {
            self.videoPlayerView.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        }
    }
    
    func deleteHighlight(videoTitle: String, highlightId: String) {
        
        if isCreator == false {
            if numberOfDeletes >= 3  {
                self.presentMaxDeleteAlert()
                return
            }
        }
        
        let alertController = UIAlertController(title: "Delete \(videoTitle) from highlights?", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            
            guard let convoId = self.conversationId, let username = globalUsername else {return}
            
            guard let logKey =  Database.database().reference().child("highlights_log").child(convoId).childByAutoId().key else {return}
            let log = [Auth.auth().currentUser?.uid: "\(username) deleted '\(videoTitle)' from highlights \u{1F4FA}"]
            
            let values = ["/conversations_highlights/\(convoId)/\(highlightId)":NSNull(),"/highlights_log/\(convoId)/\(logKey)":log] as [String : Any]
            
            Database.database().reference().updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    print ("Couldn't delete highlight from database:", error as Any)
                }
                
                Storage.storage().reference().child("conversationHighlights_imageThumbnails").child(convoId).child(videoTitle).delete(completion: { (error) in
                    if error != nil {
                        print ("Couldn't delete thumbnail image of video:", error as Any)
                    }
                    Storage.storage().reference().child("conversation_highlights").child(convoId).child(videoTitle).delete(completion: { (error) in
                        
                        if error != nil {
                            print ("Couldn't delete video from highlights:", error as Any)
                        }
                        
                        numberOfDeletes += 1
                        alertController.dismiss(animated: true, completion: nil)
                        // Some bug where the editHighlightsButton gets disabled 
                        self.editHighlightsButton.isUserInteractionEnabled = true
                        
                    })
                    
                })
                
            })
            
        }
        
        let rootViewController: UIViewController = (UIApplication.shared.windows.last?.rootViewController)!
        
        alertController.addAction(deleteAction)
        // Present w/ rootViewController so the inputAccessoryView doesn't disappear 
        rootViewController.present(alertController, animated: true, completion: nil)
        
    }
    
    var highlightsDeleteModeOn = false
    
    let highlightsLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(showHighlightsLog), for: .touchUpInside)
        button.setImage(UIImage(named: "list_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.tintColor = UIColor.black
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        return button
    }()
    
    var highlightsLogShowing = false
    
    @objc func showHighlightsLog() {
        
        if highlightsLogShowing { // Dismiss the highlights log
            highlightsLogRightConstraint?.constant = 150
            videoPlayerRightConstraint?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.highlightsLogButton.tintColor = UIColor.black
                self.highlightsLogButton.backgroundColor = .clear
                self.highlightsLogButton.layer.borderColor = UIColor.black.cgColor
            }
            highlightsLogShowing = false
        } else { // Show the highlights log
            highlightsLogRightConstraint?.constant = 0
            videoPlayerRightConstraint?.constant = -140
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.highlightsLogButton.tintColor = UIColor.white
                self.highlightsLogButton.backgroundColor = .black
                self.highlightsLogButton.layer.borderColor = UIColor.white.cgColor
            }
            highlightsLogShowing = true
        }
        
    }
    
    let editHighlightsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEditHighlightsTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleEditHighlightsTapped() {
        if highlightsDeleteModeOn {
            // We are in editing mode go off
            highlightsDeleteModeOn = false
            editHighlightsButton.tintColor = UIColor.black
            editHighlightsButton.layer.borderColor = UIColor.black.cgColor
            editHighlightsButton.backgroundColor = .clear
            videoPlayerView.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        } else {
            highlightsDeleteModeOn = true
            editHighlightsButton.tintColor = UIColor.white
            editHighlightsButton.layer.borderColor = UIColor.white.cgColor
            editHighlightsButton.backgroundColor = .black
            videoPlayerView.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        }
    }
    
    var highlightsLogRightConstraint: NSLayoutConstraint?
    
    let highlightsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setImage(UIImage(named: "highlights_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: -1, height: 1)
        button.alpha = 0
        button.addTarget(self, action: #selector(highlightsTapped), for: .touchUpInside)
        return button
    }()
    
    let eventsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setImage(UIImage(named: "events_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.alpha = 0
        button.layer.shadowOffset = CGSize(width: -1, height: 1)
        button.addTarget(self, action: #selector(handleEventsTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleEventsTapped() {
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        let eventsTableVC = EventsViewController()
        eventsTableVC.modalPresentationStyle = .overCurrentContext
        eventsTableVC.modalTransitionStyle = .coverVertical
        eventsTableVC.conversation = self.conversation
        self.present(eventsTableVC, animated: true, completion: nil)
    }
    
    @objc func handleEditButtonTapped() {
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        let editChatInfoVC = EditChatInfoViewController()
        editChatInfoVC.modalPresentationStyle = .overCurrentContext
        editChatInfoVC.modalTransitionStyle = .coverVertical
        guard let conversationId = self.conversation?.conversationId else {return}
        editChatInfoVC.conversationId = conversationId
        self.present(editChatInfoVC, animated: true, completion: nil)
    }
    
    let voteToBanButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.alpha = 0
        button.tintColor = .white
        button.setImage(UIImage(named: "block_users_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: -1, height: 1)
        button.addTarget(self, action: #selector(voteToBanTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func voteToBanTapped() {
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        let kickUserVC = KickUsersViewController()
        kickUserVC.isCreator = isCreator
        kickUserVC.conversation = self.conversation
        let navVC = UINavigationController(rootViewController: kickUserVC)
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.modalTransitionStyle = .coverVertical
        self.present(navVC, animated: true, completion: nil)
    }
    
    let reportChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.alpha = 0
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "report_chat_button"), for: .normal)
        button.addTarget(self, action: #selector(reportChatTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: -1, height: 1)
        return button
    }()
    
    @objc func reportChatTapped() {
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        let reportChatVC = ReportChatViewController()
        let navVC = UINavigationController(rootViewController: reportChatVC)
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.modalTransitionStyle = .coverVertical
        reportChatVC.conversationName = self.conversation?.conversationName
        reportChatVC.conversationId = self.conversationId
        self.present(navVC, animated: true, completion: nil)
    }
    
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.alpha = 0
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "info_button"), for: .normal)
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: -1, height: 1)
        return button
    }()
    
    @objc func infoButtonTapped() {
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        let chatInfoTBVC = ChatInfoTableViewController()
        chatInfoTBVC.isFromSearchController = fromSearchController
        // Determine how high the description of the chat is
        let contentSize = self.descriptionTestTextView.sizeThatFits(self.descriptionTestTextView.bounds.size)
        self.descriptionTestTextView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        chatInfoTBVC.chatDescriptionHeight = descriptionTestTextView.frame.height + 100
        print (chatInfoTBVC.chatDescriptionHeight)
        chatInfoTBVC.isMemberOfChat = isMemberOfChat
        chatInfoTBVC.conversation = conversation
        self.present(chatInfoTBVC, animated: true, completion: nil)
    }
    
    var highlightsButtonTopConstraint: NSLayoutConstraint?
    var editChatInfoButtonTopConstraint: NSLayoutConstraint?
    var blockUsersButtonTopConstraint: NSLayoutConstraint?
    var reportChatButtonTopConstraint: NSLayoutConstraint?
    var infoButtonTopConstraint: NSLayoutConstraint?
    
    let darkBlurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return blurView
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.trackTintColor = UIColor.clear
        pv.progressTintColor = UIColor.white
        return pv
    }()
    
    var isCreator: Bool?
    
    var fingerImageViewHorizontalAnchor: NSLayoutConstraint?
    
    fileprivate func executeFingerDrag(forHighlightsTab: Bool) {
        let fingerImageView = UIImageView()
        fingerImageView.image = UIImage(named: "one_finger")
        fingerImageView.contentMode = .scaleAspectFill
        view.addSubview(fingerImageView)
        fingerImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        fingerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        fingerImageViewHorizontalAnchor = fingerImageView.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 50)
        fingerImageViewHorizontalAnchor?.isActive = true
        
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.darkGray
        label.layer.cornerRadius = 5
        view.addSubview(label)
        if forHighlightsTab {
            label.text = "Swipe left for Highlights Tab"
            label.anchor(top: nil, left: nil, bottom: fingerImageView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 130, height: 60)
        } else {
            label.text = "Swipe left for Chat Log"
            label.anchor(top: nil, left: nil, bottom: fingerImageView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 130, height: 60)
        }
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.fingerImageViewHorizontalAnchor?.constant = -100
            UIView.animate(withDuration: 0.5, delay: 0.50, options: [], animations: {
                fingerImageView.layer.opacity = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                fingerImageView.removeFromSuperview()
            }
            UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                label.layer.opacity = 0
            }, completion: { (_) in
                label.removeFromSuperview()
            })
        }
    }
    
    fileprivate func determineOnboarding() {
        if let timesSeenFingerDrag = UserDefaults.standard.value(forKey: "timesSeenChatLogFingerDrag") as? Int {
            // User has seen it at least once -- make them see it 2 times
            if timesSeenFingerDrag <= 1 {
                let newNumber = timesSeenFingerDrag + 1
                UserDefaults.standard.set(newNumber, forKey: "timesSeenChatLogFingerDrag")
                executeFingerDrag(forHighlightsTab: true)
            } else {
                // Do nothing, the user has seen the drag enough already
            }
        } else {
            // User hasn't even seen it once
            UserDefaults.standard.set(1, forKey: "timesSeenChatLogFingerDrag")
            executeFingerDrag(forHighlightsTab: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineIfMember()
        
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        
        determineOnboarding()

        view.addSubview(mediaActivityIndicator)
        mediaActivityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        mediaActivityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        mediaActivityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(progressView)
        progressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 3)
        
        view.addSubview(uploadingLabel)
        uploadingLabel.anchor(top: progressView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 20)
        uploadingLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        view.addSubview(videoPlayerView)
        videoPlayerRightConstraint = videoPlayerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 210)
        videoPlayerRightConstraint?.isActive = true
        videoPlayerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 0)
        
        videoPlayerView.collectionView.delegate = self
        videoPlayerView.collectionView.dataSource = self
        let inputAccessoryViewHeight = self.inputAccessoryView?.bounds.height ?? 50
        videoPlayerView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputAccessoryViewHeight + 50, right: 0)
        
        videoPlayerView.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "videoCell")
        videoPlayerView.collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        videoPlayerView.collectionView.register(AddVideoCell.self, forCellWithReuseIdentifier: "addVideoCell")
        
        view.addSubview(darkBlurView)
        darkBlurView.anchor(top: nil, left: videoPlayerView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: videoPlayerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: inputAccessoryViewHeight + 5, paddingRight: 0, width: 0, height: 40)
        
        view.addSubview(editHighlightsButton)
        editHighlightsButton.anchor(top: nil, left: nil, bottom: nil, right: videoPlayerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 50, height: 30)
        editHighlightsButton.centerYAnchor.constraint(equalTo: darkBlurView.centerYAnchor).isActive = true
        
        view.addSubview(highlightsLogButton)
        highlightsLogButton.anchor(top: nil, left: videoPlayerView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        highlightsLogButton.centerYAnchor.constraint(equalTo: darkBlurView.centerYAnchor).isActive = true
        
        highlightsLogView.refreshDelegate = self 
        view.addSubview(highlightsLogView)
        highlightsLogRightConstraint = highlightsLogView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 150)
        highlightsLogRightConstraint?.isActive = true
        highlightsLogView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 0)
        
        highlightsLogView.tableView.register(TableSectionHeader.self, forHeaderFooterViewReuseIdentifier: "tableHeader")
        highlightsLogView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        highlightsLogView.tableView.delegate = self
        highlightsLogView.tableView.dataSource = self
        
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        
        if UIScreen.main.bounds.height == 812 { // iphoneX
            collectionView?.contentInset = UIEdgeInsets(top: 98, left: 0, bottom: 95, right: 0)
        } else if UIScreen.main.bounds.height == 667 { // iphone 7, iphone 8, iphone 6
            collectionView?.contentInset = UIEdgeInsets(top: 67, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 568 { // iphone5
            collectionView?.contentInset = UIEdgeInsets(top: 63, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            collectionView?.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 896 { // iphone Xs, Xr
            collectionView?.contentInset = UIEdgeInsets(top: 95, left: 0, bottom: 95, right: 0)
        }
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        highlightsLogView.tableView.register(HighlightLogTableViewCell.self, forCellReuseIdentifier: "highlightLogCellId")
        
        observeMessages()
        
        view.addSubview(highlightsButton)
        highlightsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        highlightsButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        highlightsButtonTopConstraint = highlightsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55)
        highlightsButtonTopConstraint?.isActive = true
        
        view.addSubview(eventsButton)
        eventsButton.anchor(top: nil, left: nil, bottom: nil, right: highlightsButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 50, height: 50)
        editChatInfoButtonTopConstraint = eventsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55)
        editChatInfoButtonTopConstraint?.isActive = true
        
        view.addSubview(voteToBanButton)
        voteToBanButton.anchor(top: nil, left: highlightsButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        blockUsersButtonTopConstraint = voteToBanButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55)
        blockUsersButtonTopConstraint?.isActive = true
        
        view.addSubview(reportChatButton)
        reportChatButton.anchor(top: nil, left: nil, bottom: nil, right: eventsButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 50, height: 50)
        reportChatButtonTopConstraint = reportChatButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55)
        reportChatButtonTopConstraint?.isActive = true
        
        view.addSubview(infoButton)
        infoButton.anchor(top: nil, left: voteToBanButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        infoButtonTopConstraint = infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55)
        infoButtonTopConstraint?.isActive = true
        
        navigationController?.navigationBar.tintColor = .white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.retrieveHighlights()
        }
        
        retrieveHighlightsLog()
        
    }
    
    let uploadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Wait to finish uploading..."
        label.isHidden = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        return label
    }()
    
    fileprivate func checkForCreator() {
        guard let creatorId = self.conversation?.creatorId else {return}
        if creatorId == Auth.auth().currentUser?.uid {
            isCreator = true
            let moreBtn: UIButton = UIButton(type: .custom)
            moreBtn.setImage(UIImage(named: "more_button"), for: .normal)
            moreBtn.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
            moreBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let moreButton = UIBarButtonItem(customView: moreBtn)
            
            let editBtn: UIButton = UIButton(type: .custom)
            editBtn.setImage(UIImage(named: "edit_chat_icon"), for: .normal)
            editBtn.addTarget(self, action: #selector(handleEditButtonTapped), for: .touchUpInside)
            editBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let editButton = UIBarButtonItem(customView: editBtn)
            
            navigationItem.rightBarButtonItems = [moreButton, editButton]
            
        } else {
            isCreator = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more_button"), style: .plain, target: self, action: #selector(moreButtonTapped))
        }
    }
    
    @objc func highlightsTapped() {
        
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        
        if buttonsExpanded {
            hideFloatingButtons()
        }
        
        if videoPlayerShowing && highlightsLogShowing { // Dismiss
            highlightsLogRightConstraint?.constant = 150
            videoPlayerRightConstraint?.constant = 210
            UIView.animate(withDuration: 0.3) {
                self.highlightsLogButton.backgroundColor = UIColor.clear
                self.highlightsLogButton.layer.borderColor = UIColor.black.cgColor
                self.highlightsLogButton.tintColor = UIColor.black
                self.view.layoutIfNeeded()
            }
            videoPlayerShowing = !videoPlayerShowing
            highlightsLogShowing = !highlightsLogShowing
        } else if videoPlayerShowing != true && highlightsLogShowing != true { // Show the onboarding finger
            videoPlayerRightConstraint?.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                self.showHighlightsLogOnboarding()
            }
            videoPlayerShowing = !videoPlayerShowing
        } else if videoPlayerShowing && highlightsLogShowing != true {
            videoPlayerRightConstraint?.constant = 210
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            videoPlayerShowing = !videoPlayerShowing
        }
        
    }
    
    fileprivate func showHighlightsLogOnboarding() {
        
        if let timesSeenHighlightsLogOnboarding = UserDefaults.standard.value(forKey: "timesSeenHighlightsLogFingerDrag") as? Int {
            if timesSeenHighlightsLogOnboarding <= 1 { // Show onboarding only 2 times
                let newNumber = timesSeenHighlightsLogOnboarding + 1
                UserDefaults.standard.set(newNumber, forKey: "timesSeenHighlightsLogFingerDrag")
                self.executeFingerDrag(forHighlightsTab: false)
            } else {
                // Do nothing, user has seen the drag already
            }
        } else {
            // User hasn't seen drag at all
            UserDefaults.standard.set(1, forKey: "timesSeenHighlightsLogFingerDrag")
            self.executeFingerDrag(forHighlightsTab: false)
        }
        
    }
    
    var highlightLogs = [String]()
    
    func retrieveHighlightsLog() {
        guard let conversationId = self.conversationId else {return}
        
        let highlightsLogRef = Database.database().reference().child("highlights_log").child(conversationId)
        
        let query = highlightsLogRef.queryOrderedByKey()
        
        // Use this query to only retrieve the most recent 30 logs
        query.queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.highlightsLogView.tableView.refreshControl?.endRefreshing()
            
            if snapshot.childrenCount > 0 {
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                for child in allObjects {
                    guard let dictionary = child.value as? [String:String] else {return}
                    if let text = dictionary.values.first {
                        self.highlightLogs.insert(text, at: 0)
                    }
                }
                DispatchQueue.main.async {
                    self.highlightsLogView.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highlightLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highlightLogCellId") as! HighlightLogTableViewCell
        cell.logLabel.text = highlightLogs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = highlightLogs[indexPath.row]
        let frame = estimatedFrameForText(text: text, fontSize: 16.0)
        let height = frame.height
        return height 
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableHeader") as! TableSectionHeader
        return sectionHeader 
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    @objc func backTapped() {
        guard let conversationId = self.conversationId, let uid = Auth.auth().currentUser?.uid else {return}
        // Remove firebase observer for highlights when exiting this VC
        Database.database().reference().child("conversations_highlights").child(conversationId).removeAllObservers()
        Database.database().reference().child("conversation_kickUser_votes").child(conversationId).child(uid).removeAllObservers()
        
    }
    
    var videoPlayerShowing = false
    
    @objc func swipeRightAction() {
        
        if highlightsLogShowing {
            highlightsLogRightConstraint?.constant = 150
            videoPlayerRightConstraint?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.highlightsLogButton.tintColor = UIColor.black
                self.highlightsLogButton.backgroundColor = .clear
                self.highlightsLogButton.layer.borderColor = UIColor.black.cgColor
            }
            highlightsLogShowing = !highlightsLogShowing
        } else if videoPlayerShowing && highlightsLogShowing == false {
            videoPlayerRightConstraint?.constant = 210
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            videoPlayerShowing = !videoPlayerShowing
        } else {
            // Do nothing
        }
    }
    
    @objc func swipeLeftAction() {
        
        if videoPlayerShowing && highlightsLogShowing {
            // Do nothing
        } else if videoPlayerShowing != true && highlightsLogShowing != true {
            if buttonsExpanded {
                hideFloatingButtons()
            }
            videoPlayerRightConstraint?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            videoPlayerShowing = !videoPlayerShowing
        } else if videoPlayerShowing && highlightsLogShowing != true {
            if buttonsExpanded {
                hideFloatingButtons()
            }
            videoPlayerRightConstraint?.constant = -140
            highlightsLogRightConstraint?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.highlightsLogButton.tintColor = UIColor.white
                self.highlightsLogButton.backgroundColor = .black
                self.highlightsLogButton.layer.borderColor = UIColor.white.cgColor
                self.view.layoutIfNeeded()
            }
            highlightsLogShowing = !highlightsLogShowing
        }
    }
    
    @objc func didBecomeActive() {
        let ref = Database.database().reference()
        guard let conversationId = self.conversationId else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let updateValues = ["/conversations_active_users/\(conversationId)/\(uid)":1]
        ref.updateChildValues(updateValues)
    }
    
    @objc func didEnterBackground() {
        // Delete the active user from database
        let ref = Database.database().reference()
        guard let conversationId = self.conversationId else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let updateValues = ["/conversations_active_users/\(conversationId)/\(uid)":NSNull()]
        ref.updateChildValues(updateValues)
    }
    
    // Fake text view to determine the height of the chat description for the ChatInfoTBVC
    let descriptionTestTextView: UITextView = {
        let tv = UITextView()
        return tv
    }()
    
    var buttonsExpanded = false
    
    @objc func moreButtonTapped() {
        
        if buttonsExpanded {
            hideFloatingButtons()
        } else { // Show the buttons
            highlightsButtonTopConstraint?.constant = 10
            editChatInfoButtonTopConstraint?.constant = 10
            blockUsersButtonTopConstraint?.constant = 10
            reportChatButtonTopConstraint?.constant = 10
            infoButtonTopConstraint?.constant = 10
            UIView.animate(withDuration: 0.3) {
                self.highlightsButton.alpha = 1
                self.eventsButton.alpha = 1
                self.voteToBanButton.alpha = 1
                self.reportChatButton.alpha = 1
                self.infoButton.alpha = 1
                self.view.layoutIfNeeded()
            }
            buttonsExpanded = !buttonsExpanded
        }
    }
    
    fileprivate func hideFloatingButtons() {
        highlightsButtonTopConstraint?.constant = -55
        editChatInfoButtonTopConstraint?.constant = -55
        blockUsersButtonTopConstraint?.constant = -55
        reportChatButtonTopConstraint?.constant = -55
        infoButtonTopConstraint?.constant = -55
        UIView.animate(withDuration: 0.3) {
            self.highlightsButton.alpha = 0
            self.eventsButton.alpha = 0
            self.voteToBanButton.alpha = 0
            self.reportChatButton.alpha = 0
            self.infoButton.alpha = 0
            self.view.layoutIfNeeded()
        }
        buttonsExpanded = !buttonsExpanded
    }
    
    @objc func handleKeyboardDidHide() {
        if UIScreen.main.bounds.height == 812 { // iphoneX
            collectionView?.contentInset = UIEdgeInsets(top: 98, left: 0, bottom: 95, right: 0)
        } else if UIScreen.main.bounds.height == 667 { // iphone7, iphone 6, iphone 8
            collectionView?.contentInset = UIEdgeInsets(top: 67, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 568 { // iphone 5s
            collectionView?.contentInset = UIEdgeInsets(top: 63, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            collectionView?.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 73, right: 0)
        } else if UIScreen.main.bounds.height == 896 {  // iphone Xs, Xr
            collectionView?.contentInset = UIEdgeInsets(top: 95, left: 0, bottom: 95, right: 0)
        }
    }
    // Retrieve the frame of the keyboard immediately, then compare it
    @objc func keyboardDidShow(_ notification: Notification) {
        
        if containerView.chatTextField.isFirstResponder {
            
            // This is if there are actually items in the collection view
            let indexPath = IndexPath(item: 0, section: 0)
            if UIScreen.main.bounds.height == 812 {
                collectionView?.contentInset = UIEdgeInsets(top: 365 + view.safeAreaInsets.bottom, left: 0, bottom: 95, right: 0)
            } else if UIScreen.main.bounds.height == 896 {
                collectionView?.contentInset = UIEdgeInsets(top: 375 + view.safeAreaInsets.bottom, left: 0, bottom: 100, right: 0)
            } else if UIScreen.main.bounds.height == 568 {
                collectionView?.contentInset = UIEdgeInsets(top: 315, left: 0, bottom: 73, right: 0)
            } else if UIScreen.main.bounds.height == 736 {
                collectionView?.contentInset = UIEdgeInsets(top: 330, left: 0, bottom: 73, right: 0)
            } else if UIScreen.main.bounds.height == 667 {
                collectionView?.contentInset = UIEdgeInsets(top: 323, left: 0, bottom: 73, right: 0)
            } else {
                collectionView?.contentInset = UIEdgeInsets(top: 318, left: 0, bottom: 73, right: 0)
            }
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        } else {
            return
        }
    }
    
    fileprivate func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    fileprivate func setupVideoPlayerSwipeObservers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        setupKeyboardObservers()
        setupVideoPlayerSwipeObservers()
        print ("viewWillAppear")
        // Sets up observers to catch when the app loads from the background, or goes into the background so that we can monitor the active user count
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var containerView: ChatInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let chatInputAccessoryView = ChatInputAccessoryView(frame: frame)
        chatInputAccessoryView.delegate = self
        return chatInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func determineIfMember() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let conversationId = self.conversationId else {return}
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("conversations/\(conversationId)").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() == true {
                self.isMemberOfChat = true
                self.editHighlightsButton.isEnabled = true
            } else {
                // TODO: When user joins the mob make it so the stuff isn't hidden anymore or when they text to join (handle that in here and CHATINFOTBVC)
                self.isMemberOfChat = false
                self.editHighlightsButton.isEnabled = false
            }
            
        }, withCancel: nil)
    }
    
    @objc func didSend(for text: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let conversationId = self.conversationId else {return}
        guard let characterCount = containerView.chatTextField.text?.count else {return}
        guard characterCount > 0 else {return}
        
        guard let text = containerView.chatTextField.text else {return}
        
        if containsSwearWord(text: text, swearWords: listOfSwearWords) {
            presentAlert(alert: "Check your language. Your text includes a word that is censored. Note: The censored word maybe be within a word.")
            return
        }
        
        let ref = Database.database().reference()
        
        if self.isMemberOfChat == true {
            self.sendMessage(uid: uid, convoId: conversationId)
        } else {
            
            let userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
            
            ref.updateChildValues(userConvoValues, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print ("Couldn't update userConvoValues:", error)
                }
                
                self.isMemberOfChat = true
                self.reportChatButton.isEnabled = true
                self.eventsButton.isEnabled = true
                self.voteToBanButton.isEnabled = true
                self.sendMessage(uid: uid, convoId: conversationId)
            })
        }
    }
    
    func uploadMedia() {
        
        let imagePickerController = UIImagePickerController()
        // imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            if self.isMemberOfChat == true {
                self.handleVideoSelectedForUrl(url: videoUrl, picker: picker)
                
            } else {
                guard let conversationId = self.conversation?.conversationId, let uid = Auth.auth().currentUser?.uid else {return}
                let userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
                
                Database.database().reference().updateChildValues(userConvoValues, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Couldn't update userConvoValues:", error)
                    }
                    
                    self.isMemberOfChat = true
                    self.reportChatButton.isEnabled = true
                    self.eventsButton.isEnabled = true
                    self.voteToBanButton.isEnabled = true
                    self.handleVideoSelectedForUrl(url: videoUrl, picker: picker)
                })
            }
            
        } else {
            if self.isMemberOfChat == true {
                self.handleImageSelectedForInfo(info: info, picker: picker)
            } else {
                guard let conversationId = self.conversation?.conversationId, let uid = Auth.auth().currentUser?.uid else {return}
                let userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
                
                Database.database().reference().updateChildValues(userConvoValues, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Couldn't update userConvoValues:", error)
                    }
                    
                    self.isMemberOfChat = true
                    self.reportChatButton.isEnabled = true
                    self.eventsButton.isEnabled = true
                    self.voteToBanButton.isEnabled = true 
                    self.handleImageSelectedForInfo(info: info, picker: picker)
                })
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    private func handleVideoSelectedForUrl(url: URL, picker: UIImagePickerController) {
        guard let convoId = self.conversation?.conversationId else {return}
        guard let filename = Database.database().reference().child("conversation_messages").child(convoId).childByAutoId().key else {return}
        let ref = Storage.storage().reference().child("message_movies").child(convoId).child(filename)
        
        if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
            // Use the nudity filter
            let model = Nudity()
            let inputImageSize: CGFloat = 224.0
            let minLen = min(thumbnailImage.size.width, thumbnailImage.size.height)
            let resizedImage = thumbnailImage.resize(to: CGSize(width: inputImageSize * thumbnailImage.size.width / minLen, height: inputImageSize * thumbnailImage.size.height / minLen))
            let cropedToSquareImage = resizedImage.cropToSquare()
            
            guard let pixelBuffer = cropedToSquareImage?.pixelBuffer() else {
                fatalError("Pixel buffer creation failed")
            }
            
            guard let result = try? model.prediction(data: pixelBuffer) else {
                fatalError("Prediction failed!")
            }
            
            let confidence = result.prob["\(result.classLabel)"]! * 100.0
            let possiblyNuditySFW = result.classLabel.contains("SFW") && confidence <= 70
            let possiblyNudityNFSW = result.classLabel.contains("NSFW") && confidence >= 70
            if possiblyNudityNFSW || possiblyNuditySFW {
                picker.dismiss(animated: true, completion: nil)
                self.presentNudityAlert(alert: "Your video has a \(Int(confidence))% chance of being \(result.classLabel).")
                return
            } else {
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                UIView.animate(withDuration: 0.2) {
                    self.uploadingLabel.isHidden = false
                }
                
                let uploadTask = ref.putFile(from: url, metadata: nil) { (metadata, error) in
                    
                    if let error = error {
                        print ("Failed upload of message video to storage:", error)
                    }
                    
                    ref.downloadURL(completion: { (downloadUrl, error) in
                        
                        if let error = error {
                            print ("Couldn't retrieve download url:", error)
                        }
                        
                        self.uploadToFirebaseStorageUsingThumbanilImage(filename: filename, image: thumbnailImage, completion: { (imageUrl) in
                            
                            let timestamp = NSDate().timeIntervalSince1970
                            guard let uid = Auth.auth().currentUser?.uid else {return}
                            guard let url = downloadUrl?.absoluteString else {return}
                            
                            let properties: [String:AnyObject] = ["imageUrl":imageUrl, "imageHeight": thumbnailImage.size.height, "imageWidth": thumbnailImage.size.width , "videoUrl":url, "timestamp": timestamp, "senderId":uid, "messageId": filename] as [String:AnyObject]
                            self.sendMessageWithVideoUrl(properties: properties, filename: filename, convoId: convoId, timestamp: timestamp)
                        })
                        
                    })
                    
                }
                
                uploadTask.observe(.progress) { (snapshot) in
                    
                    guard let completedUnits = snapshot.progress?.fractionCompleted else {return}
                    self.progressView.progress = Float( completedUnits)
                    
                }
                
                uploadTask.observe(.success) { (snapshot) in
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    UIView.animate(withDuration: 0.2) {
                        self.uploadingLabel.isHidden = true
                    }
                    self.progressView.progress = 0.00
                }
                
            }
        }
        
    }
    
    private func sendMessageWithVideoUrl(properties: [String:AnyObject], filename: String, convoId: String, timestamp: TimeInterval) {
        
        let updateChildValues = ["/conversations/\(convoId)/lastMessageTime/":timestamp, "/conversation_messages/\(convoId)/\(filename)/":properties] as [String:Any]
        
        Database.database().reference().updateChildValues(updateChildValues) { (error, ref) in
            
            if let error = error {
                print ("Error updating video messages:", error)
                return
            }
            
        }
        
    }
    
    private func uploadToFirebaseStorageUsingThumbanilImage(filename: String, image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        guard let conversationId = self.conversationId else {return}
        let ref = Storage.storage().reference().child("messages_imageThumbnails").child(conversationId).child(filename)
        
        // Convert image into upload data w/ a compression of 0.2
        if let uploadData = image.jpegData(compressionQuality: 0.3) {
            
            // Put the image in the database
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print ("Failed to upload image:", error as Any)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print ("Couldn't get download url:", error as Any)
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString {
                        
                        completion(imageUrl)
                        
                        
                    }
                })
                
            }
        }
    }
    
    // Generate a thumbnail image
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        
        // Provide an asset for the video
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print (error)
        }
        
        // Make return type an optional
        return nil
        
    }
    
    private func handleImageSelectedForInfo(info: [UIImagePickerController.InfoKey:Any], picker: UIImagePickerController) {
        
        var selectedImageFromPicker: UIImage?
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            // Use the nudity filter
            let model = Nudity()
            let inputImageSize: CGFloat = 224.0
            let minLen = min(selectedImage.size.width, selectedImage.size.height)
            let resizedImage = selectedImage.resize(to: CGSize(width: inputImageSize * selectedImage.size.width / minLen, height: inputImageSize * selectedImage.size.height / minLen))
            let cropedToSquareImage = resizedImage.cropToSquare()
            
            guard let pixelBuffer = cropedToSquareImage?.pixelBuffer() else {
                fatalError("Pixel buffer creation failed")
            }
            
            guard let result = try? model.prediction(data: pixelBuffer) else {
                fatalError("Prediction failed!")
            }
            
            let confidence = result.prob["\(result.classLabel)"]! * 100.0
            
            if result.classLabel.contains("NSFW") {
                picker.dismiss(animated: true, completion: nil)
                self.presentNudityAlert(alert: "Your picture has a \(Int(confidence))% chance of being NSFW.")
                return
            } else {
                uploadToFirebaseStorageUsingImage(image: selectedImage) { (imageUrl, imageName)  in
                    
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage, imageName: imageName)
                    
                }
            }
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String, _ imageName: String) -> ()) {
        guard let convoId = self.conversation?.conversationId else {return}
        guard let imageName = Database.database().reference().child("conversation_messages").child(convoId).childByAutoId().key else {return}
        guard let conversationId = self.conversationId else {return}
        let ref = Storage.storage().reference().child("conversationMessage_images").child(conversationId).child(imageName)
        
        self.mediaActivityIndicator.startAnimating()
        
        // Convert image into upload data w/ a compression of 0.2
        if let uploadData = image.jpegData(compressionQuality: 0.3) {
            
            // Put the image in the database
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print ("Failed to upload image:", error as Any)
                    self.mediaActivityIndicator.stopAnimating()
                    self.presentAlert(alert: "Could not send image. Check your connection.")
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print ("Couldn't get download url:", error as Any)
                        self.mediaActivityIndicator.stopAnimating()
                        self.presentAlert(alert: "Could not send image. Check your connection.")
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString {
                        
                        completion(imageUrl, imageName)
                        
                        
                    }
                })
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage, imageName: String) {
        let properties: [String:AnyObject] = ["imageUrl":imageUrl as AnyObject, "imageHeight": image.size.height as AnyObject, "imageWidth": image.size.width as AnyObject]
        let ref = Database.database().reference()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let convoId = self.conversationId else {return}
        let timestamp = NSDate().timeIntervalSince1970
        
        var imageValues: [String:AnyObject] = ["senderId": uid, "timestamp": timestamp] as [String:AnyObject]
        properties.forEach({imageValues[$0] = $1})
        
        let updateChildValues = ["/conversations/\(convoId)/lastMessageTime/":timestamp, "/conversation_messages/\(convoId)/\(imageName)/":imageValues] as [String:Any]
        
        ref.updateChildValues(updateChildValues) { (error, ref) in
            
            if let error = error {
                print ("Error updating image message:", error)
                self.mediaActivityIndicator.stopAnimating()
                self.presentAlert(alert: "Error uploading image to database. Check your connection")
                return
            }
            
            self.mediaActivityIndicator.stopAnimating()
            
        }
        
        self.containerView.clearChatTextField()
        
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // CUSTOM ZOOMING LOGIC --> Function is called in ChatMessageCell
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        
        // As soon as we start zooming in on the image, hide the original image
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        // Create view that will appear on top of the image frame that is tapped
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image // Set the view as the image
        
        // Handle zoom out
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissView(gesture:)))
        slideDown.direction = .down
        zoomingImageView.addGestureRecognizer(slideDown)
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            // Create black background for zoomed image
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0 // First starts out invisible
            keyWindow.addSubview(blackBackgroundView!) // Will appear behind zoom Image since it is placed first
            
            // Add red view
            keyWindow.addSubview(zoomingImageView)
            
            // Animate the zoom w/ scaling of the image
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1 // Allows for background to fade in
                
                // Hide chat area input
                self.containerView.alpha = 0
                
                // Find height using similar rects
                // h2 / w2 = h1 / w1 --> h2 = h1 / w1 * w2 (h1/w1 : starting frames)
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                // Make imageViewFrame width the width of the screen
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                // Center the imageViewFrame
                zoomingImageView.center = keyWindow.center
                
            }) { (completed) in
                // Do nothing
            }
            
        }
        
    }
    
    @objc func dismissView(gesture: UISwipeGestureRecognizer) {
        // Get reference to zoom image view
        if let zoomOutImageView = gesture.view {
            
            // Set rounded corners to the zoomOutImage
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                // Return the zoomed image view to original frame
                zoomOutImageView.frame = self.startingFrame!
                
                // Animate out the black background and bring back the text field area
                self.blackBackgroundView?.alpha = 0
                
                // Bring back chat area
                self.containerView.alpha = 1
                
            }) { (completed) in
                
                // Completely removes the zoomed imageView from the view
                zoomOutImageView.removeFromSuperview()
                
                // Bring back the original image view
                self.startingImageView?.isHidden = false
                
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        // Get reference to zoom image view
        if let zoomOutImageView = tapGesture.view {
            
            // Set rounded corners to the zoomOutImage
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                // Return the zoomed image view to original frame
                zoomOutImageView.frame = self.startingFrame!
                
                // Animate out the black background and bring back the text field area
                self.blackBackgroundView?.alpha = 0
                
                // Bring back chat area
                self.containerView.alpha = 1
                
            }) { (completed) in
                
                // Completely removes the zoomed imageView from the view
                zoomOutImageView.removeFromSuperview()
                
                // Bring back the original image view
                self.startingImageView?.isHidden = false
                
            }
        }
    }
    
    fileprivate func sendMessage(uid: String, convoId: String) {
        
        let ref = Database.database().reference()
        
        guard let text = containerView.chatTextField.text else {return}
        
        let messageTime = NSDate().timeIntervalSince1970
        let messageValues : [String:AnyObject] = ["senderId": uid as AnyObject, "text": text as AnyObject, "timestamp": messageTime as AnyObject]
        
        guard let messageKey = ref.child("conversation_messages").child(convoId).childByAutoId().key else {return}
        
        let updateChildValues = ["/conversations/\(convoId)/lastMessageTime/":messageTime, "/conversation_messages/\(convoId)/\(messageKey)/":messageValues] as [String : Any]
        
        ref.updateChildValues(updateChildValues)
        
        self.containerView.clearChatTextField()
        
    }
    
    let listOfSwearWords = ["bitch", "cock", "cunt", "whore", "pussy", "nigger"]
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        return swearWords
            .reduce(false) { $0 || text.lowercased().contains($1) }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView is HighlightsCollectionView {
            return 2
        }
        return 1 
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView is HighlightsCollectionView {
            if section == 0 {
                return highlights.count
            }
            return 1
        }
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView is HighlightsCollectionView {
            if indexPath.section == 0 {
                let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
                sectionHeader.titleLabel.text = "Highlights"
                return sectionHeader
            }
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
            sectionHeader.titleLabel.text = ""
            return sectionHeader
        }
        
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath)
        sectionHeader.frame.size.height = 0
        sectionHeader.frame.size.width = 0
        return sectionHeader
        
    }
    
    func presentAddVideoController() {
        let addVideoController = AddVideoViewController()
        addVideoController.modalPresentationStyle = .overCurrentContext
        addVideoController.conversationId = self.conversationId
        addVideoController.isMemberOfChat = isMemberOfChat

        self.present(addVideoController, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView is HighlightsCollectionView {
            if section == 0 {
                return CGSize(width: self.videoPlayerView.bounds.width, height: 50)
            } else {
                return CGSize(width:0, height: 0)
            }
        }
        return CGSize(width: 0, height: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView is HighlightsCollectionView {
            if indexPath.section == 0 {
                // These are the video cells
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
                
                if highlightsDeleteModeOn {
                    cell.deleteButton.isHidden = false
                    cell.deleteButton.isEnabled = true
                } else {
                    cell.deleteButton.isHidden = true
                    cell.deleteButton.isEnabled = false
                }
                
                cell.playHighLightDelegate = self
                let highlight = highlights[indexPath.item]

                cell.highlight = highlight
                
                return cell
            }
            // This is the add new video cell option
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addVideoCell", for: indexPath) as! AddVideoCell
            
            cell.addVideoButton.addTarget(self, action: #selector(addVideoTapped), for: .touchUpInside)
            cell.addVideoButton.addTarget(self, action: #selector(addVideoTouchDown), for: .touchDown)
            cell.addVideoButton.addTarget(self, action: #selector(addVideoTouchUpOutside), for: .touchUpOutside)
            cell.addVideoButton.addTarget(self, action: #selector(addVideoTouchDragExit), for: .touchDragExit)
            
            return cell
        }
        
        if indexPath.item == self.messages.count - 1 && isFinishedPaging == false {
            paginateMessages()
        }
        
        let message = messages[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.delegate = self
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        if let isCreator = isCreator {
            if isCreator {
                // Do nothing
                cell.deleteButton.isHidden = true
                cell.deleteModeOn = false
                
                if message.videoUrl != nil {
                    // Do onboarding check
                    performVideoMessageOnboarding()
                }
                
            } else {
                cell.deleteButton.removeFromSuperview()
            }
        }
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text, fontSize: 16.0).width + 32
            cell.bubbleWidthAnchor?.isActive = true
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
            if message.videoUrl != nil {
                cell.videoUrl = message.videoUrl
            }
        }
        
        // Check if the user is blocked, if so block the text (image check is in setupCell func)
        if listOfBlockedUsers.contains(message.senderId ?? "") {
            cell.textView.text = ""
            cell.playButton.isHidden = true
            cell.playButton.isEnabled = false
        } else {
            cell.textView.text = message.text
        }
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    fileprivate func performVideoMessageOnboarding() {
        if let timesSeenVideoMessageOnboarding = UserDefaults.standard.value(forKey: "timesSeenVideoMessageOnboarding") as? Int {
            if timesSeenVideoMessageOnboarding < 1 { // Show onboarding only 1 time
                let newNumber = timesSeenVideoMessageOnboarding + 1
                UserDefaults.standard.set(newNumber, forKey: "timesSeenVideoMessageOnboarding")
                self.videoMessageOnboarding()
            } else {
                // Do nothing, user has seen the drag already
            }
        } else {
            // User hasn't seen drag at all
            UserDefaults.standard.set(1, forKey: "timesSeenVideoMessageOnboarding")
            self.videoMessageOnboarding()
        }
    }

    fileprivate func videoMessageOnboarding() {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.darkGray
        label.layer.cornerRadius = 5
        view.addSubview(label)
        label.text = "Long press on video messages to show/hide delete button"
        label.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 80)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let fingerImageView = UIImageView()
        fingerImageView.image = UIImage(named: "one_finger")
        fingerImageView.contentMode = .scaleAspectFill
        view.addSubview(fingerImageView)
        fingerImageView.anchor(top: label.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        fingerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
            UIView.animate(withDuration: 1.0, delay: 0.50, options: [], animations: {
                fingerImageView.layer.opacity = 0
            }) { (_) in
                fingerImageView.removeFromSuperview()
            }
            UIView.animate(withDuration: 1.0, delay: 2.0, options: [], animations: {
                label.layer.opacity = 0
            }, completion: { (_) in
                label.removeFromSuperview()
            })
        
    }

    
    var player: AVPlayer?
    
    func playHighlight(url: String) {
        guard let videoUrl = URL(string: url) else {return}
        player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    func playMessageVideo(url: URL) {
        player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalTransitionStyle = .coverVertical
        playerViewController.modalPresentationStyle = .overCurrentContext
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    @objc func addVideoTapped() {
        let cell = videoPlayerView.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! AddVideoCell
        if highlights.count >= 15 {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
                cell.addVideoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (_) in
                UIView.animate(withDuration: 0.3, animations: {
                    cell.addVideoButton.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.presentAlert(alert: "You can only have 15 highlights. ")
                })
            }
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            cell.addVideoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                cell.addVideoButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.presentAddVideoController()
            })
        }
    }
    
    @objc func addVideoTouchDown() {
        let cell = videoPlayerView.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! AddVideoCell
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            cell.addVideoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func addVideoTouchUpOutside() {
        let cell = videoPlayerView.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! AddVideoCell
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            cell.addVideoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func addVideoTouchDragExit() {
        let cell = videoPlayerView.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! AddVideoCell
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            cell.addVideoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    var previousUser: User?
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        guard let senderId = message.senderId else {return}
        if senderId == Auth.auth().currentUser?.uid { // Sender is the current user
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            cell.textView.textColor = .white
            
            cell.profileImageView.isHidden = true
            cell.nameLabel.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
            cell.bubbleViewNameAnchor?.isActive = false
            cell.bubbleViewBottomAnchor?.isActive = true
            cell.bubbleViewTopAnchor?.isActive = true
            
        } else { // Sender isn't the current user
            
            if senderId == previousUser?.uid {
                cell.profileImageView.loadImage(urlString: (previousUser?.profileImageUrl)!)
                cell.nameLabel.text = previousUser?.username
            } else {
                Database.database().reference().child("users").child(senderId).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
                    let user = User(uid: senderId, dictionary: dictionary)
                    self.previousUser = user
                    
                    guard let profileImageUrl = user.profileImageUrl else {return}
                    cell.profileImageView.loadImage(urlString: profileImageUrl)
                    cell.nameLabel.text = user.username
                }, withCancel: nil)
            }
            
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            
            cell.profileImageView.isHidden = false
            cell.nameLabel.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
            cell.bubbleViewTopAnchor?.isActive = false
            cell.bubbleViewNameAnchor?.isActive = true
            cell.bubbleViewBottomAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            // Check if the user is blocked, if so block the image
            if listOfBlockedUsers.contains(message.senderId ?? "") {
                cell.messageImageView.isHidden = true
            } else {
                cell.messageImageView.isHidden = false
                cell.messageImageView.loadImage(urlString: messageImageUrl)
                cell.bubbleView.backgroundColor = UIColor.clear
            }
        } else {
            cell.messageImageView.isHidden = true
        }
        
    }
    
    func accessProfile(indexPath: IndexPath) {
        
        if containerView.chatTextField.isFirstResponder {
            containerView.chatTextField.resignFirstResponder()
        }
        
        let message = messages[indexPath.item]
        let senderId = message.senderId
        let bioVC = ChatLogBioViewController()
        bioVC.popChatLogControllerDelegate = self 
        bioVC.fromTableViewController = false
        bioVC.uid = senderId
        self.navigationController?.pushViewController(bioVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView is HighlightsCollectionView {
            
            if indexPath.section == 0 {
                return CGSize(width: self.videoPlayerView.bounds.width - 10, height: 155)
            }
            return CGSize(width: self.videoPlayerView.bounds.width - 10, height: 120)
        }
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if message.senderId == Auth.auth().currentUser?.uid {
            if let text = message.text {
                height = estimatedFrameForText(text: text, fontSize: 16.0).height + 20
            } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                height = CGFloat(imageHeight / imageWidth * 200) + 20
            }
        } else { // We need extra height for the name label for users not ourselves
            if let text = message.text {
                height = estimatedFrameForText(text: text, fontSize: 16.0).height + 40
            } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                height = CGFloat(imageHeight / imageWidth * 200) + 20
            }
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        if highlights.count == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func estimatedFrameForText(text: String, fontSize: CGFloat) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize)], context: nil)
    }
    
    // Alert function
    func presentAlert(alert:String) {
        
        let alertVC = UIAlertController(title: "Nope", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func presentHighlightAlert() {
        
        let alertVC = UIAlertController(title: "Max number of highlights reached.", message: "You can only have 15 highlights up at a time. Delete some to post more.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func presentNudityAlert(alert:String) {
        
        let alertVC = UIAlertController(title: "Potential Nudity Detected", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func presentMaxDeleteAlert() {
        let alertVC = UIAlertController(title: "Max Deletes Reached", message: "Each member has only 3 delete tokens per session.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
}

// MARK: Nudity Filter Extension
extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func cropToSquare() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        var imageHeight = self.size.height
        var imageWidth = self.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        let x = ((CGFloat(cgImage.width) - size.width) / 2).rounded()
        let y = ((CGFloat(cgImage.height) - size.height) / 2).rounded()
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let croppedCgImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCgImage, scale: 0, orientation: self.imageOrientation)
        }
        
        return nil
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}


