import UIKit
import FirebaseDatabase
import FirebaseMessaging
import FirebaseAuth

var listOfBlockedUsers = [String]()

// TODO: Create a user cache -- update the user cache too with stuff 
class MessagesController: UITableViewController, UINavigationBarDelegate {
    
    var user: User?
    
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isUserInteractionEnabled = true
        if let profileImageUrl = globalProfileImageUrl, let name = globalUsername {
            profileImageView.loadImage(urlString: profileImageUrl)
            nameLabel.text = name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.separatorStyle = .none
        
        self.navigationController?.navigationBar.frame = CGRect(x: 10, y: 10, width: (navigationController?.navigationBar.frame.width)!, height: (navigationController?.navigationBar.frame.height)!)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        
        tableView.backgroundView = backgroundView
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(MessagePreviewCell.self, forCellReuseIdentifier: cellId)
        
        fetchUserAndSetupNavBarTitle()
        
        fetchListOfBlockedUsers()
        
    }
    
    func fetchListOfBlockedUsers() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users_blocked").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
            for (key, _) in dictionary {
                listOfBlockedUsers.append(key)
            }
        }
        
    }
    
    @objc func handleCreateNewConversation() {
        let newConvoController = CreateNewConvoController()
        let navController = UINavigationController(rootViewController: newConvoController)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String:Any] else {return}
            
            // Update the fcmToken into the user database for users who created accounts before the recent update 
            if userDictionary["fcmToken"] == nil {
                guard let fcmToken = Messaging.messaging().fcmToken else {return}
                let fcmValues = ["fcmToken": fcmToken]
                Database.database().reference().child("users").child(uid).updateChildValues(fcmValues)
            }
            
            let user = User(uid: uid, dictionary: userDictionary)
            self.setupNavBarWithUser(user: user)
            
        }) { (error) in
            print ("Failed to fetch user for posts:", error)
        }
        
    }
    
    var totalRequiredConversationCount: Int?
    
    func observeUserConvos() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("users").child(uid).child("conversations")
        
        ref.observe(.childAdded, with: { (snapshot) in
            let convoId = snapshot.key
            self.totalRequiredConversationCount = Int(snapshot.childrenCount)
            self.fetchConversationWithConvoId(convoId: convoId)
        }, withCancel: nil)
        
        // Watch for when we delete a convo from within the database and delete the convo from the app
        ref.observe(.childRemoved, with: { (snapshot) in
            self.conversationDict.removeValue(forKey: snapshot.key)
            ref.child("conversations_active_users").child(snapshot.key).removeAllObservers() // When we leave this chat stop observing for its active users
            self.reloadTable()
            
        }, withCancel: nil)
        
    }
    
    var conversations = [Conversation]()
    var conversationDict = [String:Conversation]()
    
    private func fetchConversationWithConvoId(convoId: String) {
        
        let convoRef = Database.database().reference().child("conversations").child(convoId)
        convoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let conversation = Conversation(dictionary: dictionary)
                let convoId = snapshot.key
                
                Database.database().reference().child("conversation_users").child(convoId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    conversation.numberOfMembers = Int(snapshot.childrenCount)
                    
                    self.conversationDict[convoId] = conversation
                    
                    self.reloadTable()
                    
                    // TODO: May have to check this with slower internet connection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        // Check if the # of conversations is = number of snapshot.children 
                        self.determineActiveUserCount(conversation: conversation)
                    })
                    
                })
                
            }
        }, withCancel: nil)
        
    }
    
    func determineActiveUserCount(conversation: Conversation) {
        
            guard let conversationId = conversation.conversationId else {return}

        let ref = Database.database().reference()
            ref.child("conversations_active_users").child(conversationId).observe(.value, with: { (snapshot) in
                
                // Update values of the specific conversation
                conversation.numberOfMembersOnline = Int(snapshot.childrenCount)
                
                // Retrieve the index of the conversation located in the conversations array
                guard let indexOfConvo = self.conversations.firstIndex(of: conversation) else {return}

                let indexPath = IndexPath(row: indexOfConvo, section: 0)
                
                // Do this so we don't get a weird table view animation
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
                
            }, withCancel: nil)
            
        
        
    }
    
    func reloadTable() {
        self.conversations = Array(self.conversationDict.values)
        
        self.conversations.sort { (c1, c2) -> Bool in
            return (c1.lastMessageTime?.intValue)! > (c2.lastMessageTime?.intValue)!
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    let profileImageView: CustomImageView = {
        let profileImageView = CustomImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.adjustsFontSizeToFitWidth = true 
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        return nameLabel
    }()
    
    func setupNavBarWithUser(user: User) {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_chat_icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCreateNewConversation))
        
        observeUserConvos()
        
        let titleView = UIView()
        titleView.isUserInteractionEnabled = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        // Create new container new to put into titleView
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.username
        globalUsername = user.username 
        
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        nameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessagePreviewCell
        cell.translatesAutoresizingMaskIntoConstraints = true
        
        let conversation = conversations[indexPath.row]
        
        // Update the aspects of the conversation cell 
        if let numberOfActiveMembers = conversation.numberOfMembersOnline {
            if let numberOfMembers = conversation.numberOfMembers {
                cell.activeUserCount = numberOfActiveMembers
                if numberOfActiveMembers > 0 {
                    cell.activeStateImage.isHidden = false
                    cell.activeUserCountLabel.text = String(numberOfActiveMembers)
                } else {
                    cell.activeStateImage.isHidden = true
                    cell.activeUserCountLabel.text = String(numberOfMembers)
                }
            }
        }
        
        cell.conversation = conversation
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            let conversation = conversations[indexPath.row]
            
            guard let conversationId = conversation.conversationId, let conversationName = conversation.conversationName else {return}
            
            // The user will be required to refresh the app to have themselves be unbanned again
            if bannedConversations.contains(conversationId) {
                let alertController = UIAlertController(title: "You have been banned from \(conversationName)", message: "Enough members voted to ban you. Please conduct yourself accordingly next time.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "\u{1F62D}\u{1F62D}\u{1F62D}\u{1F62D}", style: .default, handler: { (_) in
                    alertController.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                tableView.isUserInteractionEnabled = false

                self.showChatController(convo: conversation, convoId: conversationId)
            }
        
    }
    
    func showChatController(convo: Conversation, convoId: String) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.conversation = convo
        chatLogController.fromSearchController = false
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
