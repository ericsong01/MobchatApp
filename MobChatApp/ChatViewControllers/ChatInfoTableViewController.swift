import UIKit
import EventKit
import Firebase
import UserNotifications

protocol ActivityIndicatorProtocol: class {
    func stopActivityIndicator()
}

protocol ReloadCollectionViewProtocol: class {
    func reloadCollectionView()
}

protocol LeaveJoinChatProtocol: class {
    func leaveChat()
    func joinChat()
}

class ChatInfoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LeaveJoinChatProtocol, ActivityIndicatorProtocol {
    
    var isFromSearchController: Bool?
    var isMemberOfChat: Bool?
    var users = [User]()
    
    weak var changingLeaveToJoinMobButtonChangeDelegate: ChangingLeaveJoinChatButtonsProtocol!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCellId", for: indexPath) as! UserCollectionViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 5 - 20)/4
        let height = width * 1.25
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 1 pixl between rows
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 1 pixl between columns
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let bioVC = ChatLogBioViewController()
        bioVC.fromTableViewController = true 
        bioVC.uid = user.uid
        present(bioVC, animated: true, completion: nil)
    }
    
    var chatDescription: String?
    var chatTimestamp: String?
    var chatCreator: String?
    var creatorProfileImageUrl: String?
    
    var conversation: Conversation? {
        didSet {
            
            guard let conversationImageUrl = conversation?.imageUrl else {return}
            chatView.chatImageView.loadImage(urlString: conversationImageUrl)
            
            guard let conversationName = conversation?.conversationName else {return}
            chatView.chatLabel.text = conversationName
            
            chatDescription = conversation?.chatIntroDescription
            
            if let second = conversation?.chatTimestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: second)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                chatTimestamp = dateFormatter.string(for: timestampDate)
            }
            
        }
    }
    
    var convoMemberText: String?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
        
    fileprivate func retrieveListOfUsers() {
        
        let ref = Database.database().reference()
        guard let conversationId = conversation?.conversationId else {return}
        ref.child("conversation_users").child(conversationId).observeSingleEvent(of: .value, with: { (snapshot) in
            let memberCount = snapshot.childrenCount
            if memberCount == 0 {
                self.activityIndicatorView.stopAnimating()
            }
            var memberText = "member"
            if snapshot.childrenCount > 1 || snapshot.childrenCount == 0 {
                memberText = "members"
            }
            self.convoMemberText = "\(memberCount) \(memberText)"
            
            guard let dictionaries = snapshot.value as? [String:AnyObject] else {return}
            
            for (key, _) in dictionaries {
                let userId = key
                Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let userDictionary = snapshot.value as? [String:Any] else {return}
                    
                    let user = User(uid: userId, dictionary: userDictionary)
                    
                    self.users.append(user)
                    
                }, withCancel: nil)
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                // Reloading the table view also reloads the collection view
                self.tableView.performBatchUpdates({
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }, completion: { (_) in
                    self.activityIndicatorView.stopAnimating()
                })
            })
        }, withCancel: nil)
    }
    
    func stopActivityIndicator() {
        self.activityIndicatorView.stopAnimating()
    }
        
    let generalCellId = "generalCellId"
    let usersCellId = "usersCellId"
    let eventsParentCellId = "eventsParentCellId"
    
    weak var reloadDelegate: ReloadCollectionViewProtocol!
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "share_icon"), for: .normal)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 20
        return button
    }()
    
    @objc func shareButtonTapped() {
        guard let conversationName = self.conversation?.conversationName else {return}
        let url = "https://itunes.apple.com/us/app/mobchat/id1435966141?ls=1&mt=8"
        let text = "Join \(conversationName) on MobChat. It's \u{1F525}\u{1F525}\u{1F525}"
        let activityController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    var chatViewHeight = (180/667) * UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.startAnimating()
            
        view.backgroundColor = UIColor.white
        
        tableView.showsVerticalScrollIndicator = false
        
        view.layer.configureGradientBackground(UIColor(red: 1.000, green: 0.3647, blue: 0.6863, alpha: 1).cgColor, UIColor(red: 0.6392, green: 0.4314, blue: 0.9373, alpha: 1).cgColor)
        
        view.addSubview(tableView)
        
        chatView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: chatViewHeight)
        view.addSubview(chatView)
        chatView.backgroundColor = .clear
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: (12/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 40/375).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1).isActive = true
        
        view.addSubview(shareButton)
        shareButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: (12/375) * view.bounds.width, width: 0, height: 0)
        shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 40/375).isActive = true
        shareButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor, multiplier: 1).isActive = true
        
        // Do this so that the table view doesn't erratically scroll on reloads, and so we can also load the VC at the top with the chatView all the way down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableView.estimatedRowHeight = 0 // This prevents table view from scrolling wierdly
        }
        
        tableView.backgroundColor = .clear
        
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        tableView.contentInset = UIEdgeInsets(top: chatViewHeight, left: 0, bottom: 0, right: 0)
        
        tableView.separatorStyle = .none
        
        tableView.register(GeneralChatInfoCell.self, forCellReuseIdentifier: generalCellId)
        tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: usersCellId)
        tableView.register(EventsParentTableViewCell.self, forCellReuseIdentifier: eventsParentCellId)
                
        retrieveListOfUsers()
        
        determineNotificationStatusForChat()
        
        determineIfNotificationsAreActivatedForDevice()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    var deviceHasNotificationsActivated: Bool?
    var chatHasNotificationsActivated: Bool?
    
    private func determineIfNotificationsAreActivatedForDevice() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                // Push notifications authorized
                self.deviceHasNotificationsActivated = true
            } else {
                // Push notifications not determined or unauthorized
                self.deviceHasNotificationsActivated = false
            }
        }
    }
    
    private func determineNotificationStatusForChat() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let convoId = self.conversation?.conversationId else {return}
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("conversations_notifications_active").child(convoId).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                self.chatHasNotificationsActivated = true
                if let delegate = self.hideLeaveJoinChatButtonsDelegate {
                    delegate.turnNotificationSwitchOn()
                }
            } else {
                self.chatHasNotificationsActivated = false
                if let delegate = self.hideLeaveJoinChatButtonsDelegate {
                    delegate.turnNotificationSwitchOff()
                }
            }
        }
    }
    
    var chatDescriptionHeight: CGFloat? 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up observer to see when app loads from the background
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didBecomeActive() {
        if let isMemberOfChat = isMemberOfChat {
            if isMemberOfChat {
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    if settings.authorizationStatus == .authorized {
                        // Push notifications authorized
                        self.deviceHasNotificationsActivated = true
                        if let delegate = self.hideLeaveJoinChatButtonsDelegate {
                            delegate.enableNotificationSwitch()
                        }
                    } else {
                        // Push notifications not determined or unauthorized
                        self.deviceHasNotificationsActivated = false
                        if let delegate = self.hideLeaveJoinChatButtonsDelegate {
                            delegate.disableNotificationSwitch()
                        }
                    }
                }
            } else {
                // Do nothing
                print ("isn't member of chat, so don't touch the switch")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let convoId = conversation?.conversationId else {return}
        
        Database.database().reference().child("conversation_notifications").child(convoId).removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if let chatDescriptionHeight = chatDescriptionHeight {
                return chatDescriptionHeight + 200
            }
            print (chatDescriptionHeight)
            return 500
        } else if indexPath.row == 1 {
            let width = (UIScreen.main.bounds.width - 5 - 20)/4
            let height = width * 1.25
            let usersCellHeight = returnHeightOfUsersTableViewCell(height: height)
            return usersCellHeight
        }
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    weak var hideLeaveJoinChatButtonsDelegate: HandleSwitchLeaveJoinChatButtonsProtocol!
    
    var creatorUser: User?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let generalCell = tableView.dequeueReusableCell(withIdentifier: generalCellId, for: indexPath) as! GeneralChatInfoCell
            
            generalCell.selectionStyle = .none
            generalCell.backgroundColor = .clear
            generalCell.chatDescriptionTextView.text = chatDescription
            generalCell.timestampLabel.text = chatTimestamp
            generalCell.creatorLabel.text = chatCreator
            
            generalCell.membersLabel.text = self.convoMemberText
            
            // Check if the creator already exists -- If it does don't fetch from database
            if let creator = creatorUser {
                generalCell.creatorLabel.text = creator.username
                if let profileImageUrl = creator.profileImageUrl {
                    generalCell.creatorProfileImage.loadImage(urlString: profileImageUrl)
                }
            } else {
                if let creatorId = conversation?.creatorId {
                    Database.fetchUsersWithUID(uid: creatorId) { (user) in
                        self.creatorUser = user
                        generalCell.creatorLabel.text = user.username
                        guard let profileImageUrl = user.profileImageUrl else {return}
                        generalCell.creatorProfileImage.loadImage(urlString: profileImageUrl)
                    }
                }
            }
            
            return generalCell
            
        } else if indexPath.row == 1 {
            let usersCell = tableView.dequeueReusableCell(withIdentifier: usersCellId, for: indexPath) as! UsersTableViewCell
            usersCell.backgroundColor = .clear
            usersCell.selectionStyle = .none
            usersCell.activityIndicatorDelegate = self
            self.reloadDelegate = usersCell
            // usersCell.users = users
            usersCell.collectionView.delegate = self
            usersCell.collectionView.dataSource = self 
            return usersCell
        }
        
        let eventsParentCell = tableView.dequeueReusableCell(withIdentifier: eventsParentCellId, for: indexPath) as! EventsParentTableViewCell
        
        eventsParentCell.leaveJoinChatDelegate = self
        self.changingLeaveToJoinMobButtonChangeDelegate = eventsParentCell
        self.hideLeaveJoinChatButtonsDelegate = eventsParentCell
        eventsParentCell.conversation = self.conversation
        
        eventsParentCell.deviceHasNotificationsActivated = self.deviceHasNotificationsActivated
        
        if let chatHasNotificationsActivated = self.chatHasNotificationsActivated {
            if chatHasNotificationsActivated {
                eventsParentCell.notificationSwitch.isOn = true
            } else {
                eventsParentCell.notificationSwitch.isOn = false
            }
        }
        
        if let isMemberOfChat = isMemberOfChat {
            if isMemberOfChat {
                eventsParentCell.leaveChatButton.isEnabled = true
                eventsParentCell.leaveChatButton.isHidden = false
                
                // Enable notification switch based on if the app has notifications enabled
                if deviceHasNotificationsActivated ?? false {
                    eventsParentCell.notificationSwitch.isEnabled = true
                } else {
                    eventsParentCell.notificationSwitch.isEnabled = false
                }
                
            } else { // User is not a part of the convo
                eventsParentCell.joinChatButton.isEnabled = true
                eventsParentCell.joinChatButton.isHidden = false
                eventsParentCell.notificationSwitch.isEnabled = false
            }
        }
        
        return eventsParentCell
        
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 10
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    let chatView: ChatUIView = {
        let view = ChatUIView()
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "left_button"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = UIColor.white
        return button
    }()
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Header Scrolling Control
    
    var minHeaderHeight: CGFloat = {
        if UIScreen.main.bounds.height > 736 || UIApplication.shared.statusBarFrame.height > 20 {
            return ((UIApplication.shared.statusBarFrame.height + 30)/667) * UIScreen.main.bounds.height
        } else if UIScreen.main.bounds.height == 568 {
            return (75/667) * UIScreen.main.bounds.height
        } else {
            return (67/667) * UIScreen.main.bounds.height
        }
    }()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = chatViewHeight - (scrollView.contentOffset.y + chatViewHeight)
        
        let height = min(max(y, minHeaderHeight), 400)
        
        let range = self.chatViewHeight - self.minHeaderHeight
        let openAmount = self.chatViewHeight - height
        let percentage = openAmount / range
        chatView.blurView.alpha = percentage
        
        chatView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
    
    // MARK: Leave and Join Chat Funcs 
    
    func leaveChat() {
        guard let convoName = self.conversation?.conversationName else {return}
        
        let alertController = UIAlertController(title: "Leave \(convoName)?", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.preferredAction = cancelAction
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let convoId = self.conversation?.conversationId else {return}
        let ref = Database.database().reference()
        
        var childUpdates = ["/users/\(uid)/conversations/\(convoId)":NSNull(), "/conversation_users/\(convoId)/\(uid)":NSNull(), "/users/\(uid)/conversations_notifications_active/\(convoId)":NSNull()]
        
        if let notificationsActivated = deviceHasNotificationsActivated {
            if notificationsActivated {
                childUpdates = ["/users/\(uid)/conversations/\(convoId)":NSNull(), "/conversation_users/\(convoId)/\(uid)":NSNull(), "/users/\(uid)/conversations_notifications_active/\(convoId)":NSNull()]
            } else {
                childUpdates = ["/users/\(uid)/conversations/\(convoId)":NSNull(), "/conversation_users/\(convoId)/\(uid)":NSNull()]
            }
        }
        
        let leaveChatAction = UIAlertAction(title: "Leave", style: .default) { (action) in
            ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print ("Couldn't delete convo ID from users and convo node:", error)
                    return
                }
                self.isMemberOfChat = false
                let chatLogController = ChatLogController()
                chatLogController.isMemberOfChat = false
                self.changingLeaveToJoinMobButtonChangeDelegate.leaveToJoinMobButtonChange()
            })
        }
        
        alertController.addAction(leaveChatAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func joinChat() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let conversationId = conversation?.conversationId else {return}
        
        var userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
        
        // Determine if database should be updated depending on if the device is notifications activated
        if let notificationsActivated = deviceHasNotificationsActivated {
            if notificationsActivated {
                userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
            } else {
                userConvoValues = ["/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1]
            }
        }
        
        Database.database().reference().updateChildValues(userConvoValues) { (error, ref) in
            if let error = error {
                print ("Couldn't update userConvoValues:", error)
                return
            }
            let chatLogController = ChatLogController()
            self.isMemberOfChat = true 
            chatLogController.isMemberOfChat = true
            self.changingLeaveToJoinMobButtonChangeDelegate.joinToLeaveMobButtonChange()
        }
    }
    
    // Alert function
    func presentAlert(alert:String) {
        let alertVC = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // Calculating height of table view cells
    func returnHeightOfUsersTableViewCell(height: CGFloat) -> CGFloat {
        if users.count == 0 {
            return 50
        } else if users.count <= 4 {
            return height + 50
        } else if users.count <= 8 {
            return 2 * (height) + 50
        } else if users.count <= 12 {
            return 3 * (height) + 50
        } else if users.count <= 16 {
            return 4 * (height) + 50
        } else if users.count <= 20 {
            return 5 * (height) + 50
        } else if users.count <= 24 {
            return 6 * (height) + 50
        } else if users.count <= 28 {
            return 7 * (height) + 50
        } else if users.count <= 32 {
            return 8 * (height) + 50
        } else if users.count <= 36 {
            return 9 * (height) + 50
        } else if users.count <= 40 {
            return 10 * (height) + 50
        } else if users.count <= 44  {
            return 11 * (height) + 50
        } else if users.count <= 48 {
            return 12 * (height) + 50
        } else if users.count <= 52 {
            return 13 * (height) + 50
        } else if users.count <= 56 {
            return 14 * (height) + 50
        } else if users.count <= 60 {
            return 15 * (height) + 50
        } else if users.count <= 64 {
            return 16 * (height) + 50
        } else if users.count <= 68 {
            return 17 * (height) + 50
        } else if users.count <= 72 {
            return 18 * (height) + 50
        } else if users.count <= 76 {
            return 19 * (height) + 50
        } else if users.count <= 80 {
            return 20 * (height) + 50
        } else if users.count <= 84 {
            return 21 * (height) + 50
        } else if users.count <= 88 {
            return 22 * (height) + 50
        } else if users.count <= 92 {
            return 23 * (height) + 50
        } else if users.count <= 96 {
            return 24 * (height) + 50
        } else if users.count <= 100 {
            return 25 * (height) + 50
        } else if users.count <= 104 {
            return 26 * (height) + 50
        } else if users.count <= 108 {
            return 27 * (height) + 50
        } else if users.count <= 112 {
            return 28 * (height) + 50
        } else if users.count <= 116 {
            return 29 * (height) + 50
        } else if users.count <= 120 {
            return 30 * (height) + 50
        } else if users.count <= 124 {
            return 31 * (height) + 50
        } else if users.count <= 128 {
            return 32 * (height) + 50
        } else if users.count <= 132 {
            return 33 * (height) + 50
        } else if users.count <= 136 {
            return 34 * (height) + 50
        }
        return 5000
    }
    
}
