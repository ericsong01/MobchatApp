import UIKit
import Firebase

protocol KickUserVoteProtocol: class {
    func voteToKickUserWithUid(uid: String, username: String)
    func voteToUnBanUser(uid: String, username: String)
}

class KickUsersViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, KickUserVoteProtocol {
    
    var isCreator: Bool?
    
    var conversation: Conversation?
    
    func voteToUnBanUser(uid: String, username: String) {
        guard let conversationId = self.conversation?.conversationId, let currentUserUid = Auth.auth().currentUser?.uid, let myUsername = globalUsername else {return}
        
        let alertController = UIAlertController(title: "Vote to unban \(username)?", message: "If the user receives 3 votes, they will be unbanned from the conversation.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        let unbanAction = UIAlertAction(title: "Unban", style: .destructive) { (_) in
            
            let ref = Database.database().reference()
            
            guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
            
            var log = [currentUserUid: "\(myUsername) voted to unban \(username)"]
            var values = ["/conversations_bannedUsers/\(conversationId)/\(uid)/\(currentUserUid)":1, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
        
            if self.isCreator ?? false { // Automatically unban users 
                log = [currentUserUid: "The creator '\(myUsername)' unbanned \(username)"]
                values = ["/conversation_kickUser_votes/\(conversationId)/\(uid)": NSNull(), "/conversations_bannedUsers/\(conversationId)/\(uid)":NSNull(), "/highlights_log/\(conversationId)/\(logKey)":log] as [String : AnyObject]
            }
            
            ref.updateChildValues(values) { (error, ref) in
                
                if let error = error {
                    print ("Couldn't unban user:", error)
                    return
                }
                
                alertController.dismiss(animated: true, completion: nil)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(unbanAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func voteToKickUserWithUid(uid: String, username: String) {
        guard let conversationId = self.conversation?.conversationId, let currentUserUid = Auth.auth().currentUser?.uid, let myUsername = globalUsername else {return}
    
        if uid == currentUserUid {
            let alertController = UIAlertController(title: "You can't vote to ban yourself", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let alertController = UIAlertController(title: "Vote to ban \(username)?", message: "If the user receives 3 votes, they will be banned from the conversation.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        let banAction = UIAlertAction(title: "Ban", style: .destructive) { (_) in
            
            let ref = Database.database().reference()

            guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
            let timestampValue = ["timestamp":NSDate().timeIntervalSince1970]
            
            var log = [currentUserUid: "\(myUsername) voted to ban \(username) \u{26D4}"]
            var values = ["/conversation_kickUser_votes/\(conversationId)/\(uid)/\(currentUserUid)":timestampValue, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
            
            if self.isCreator ?? false && uid != currentUserUid {
                log = [currentUserUid: "The creator '\(myUsername)' has banned \(username) \u{1F6AB}"]
                values = ["/conversation_kickUser_votes/\(conversationId)/\(uid)/\(currentUserUid)":timestampValue, "/conversation_kickUser_votes/\(conversationId)/\(uid)/creatorVote2/":timestampValue, "/conversation_kickUser_votes/\(conversationId)/\(uid)/creatorVote3/":timestampValue, "/conversations_bannedUsers/\(conversationId)/\(uid)":1, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
            }

            ref.updateChildValues(values) { (error, ref) in
             
                if let error = error {
                    print ("Couldn't ban user:", error)
                    return
                }
                
                alertController.dismiss(animated: true, completion: nil)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(banAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        }
        return bannedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "kickUserCellId", for: indexPath) as! KickUserTableViewCell
            cell.user = users[indexPath.row]
            cell.kickUserDelegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "unbanUserCellId", for: indexPath) as! UnBanUserTableViewCell
        cell.user = bannedUsers[indexPath.row]
        cell.kickUserDelegate = self
        return cell

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Vote to Ban User"
        }
        if bannedUsers.count > 0 {
            return "Vote to Unban User"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    var users = [User]()
    var bannedUsers = [User]()
    
    let tableView: UITableView = {
       let tableView = UITableView(frame: CGRect(x: 50, y: 50, width: 50, height: 50), style: .grouped)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowOpacity = 1
        view.alpha = 0
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Users are banned/unbanned with 3 votes from members \n\n Creators can ban/unban with one vote. \n\n Only one vote per user is counted towards the total vote count. \n\n Users will be able to see if you have voted to ban/unban others \n\n If you go on a banning spree, you may be banned yourself"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func okTapped() {
        UIView.animate(withDuration: 0.5, animations: {
            self.infoView.alpha = 0
        }) { (_) in
            self.infoView.removeFromSuperview()
        }
        infoButtonTapped = false
    }
    
    var infoButtonTapped = false
    
    @objc func infoTapped() {
        
        if infoButtonTapped {
            // Dismiss the view
            UIView.animate(withDuration: 0.5, animations: {
                self.infoView.alpha = 0
            }) { (_) in
                self.infoView.removeFromSuperview()
            }
            infoButtonTapped = false
        } else {
            view.addSubview(infoView)
            infoView.addSubview(infoLabel)
            infoView.addSubview(okButton)
            
            infoView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 300)
            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            okButton.anchor(top: nil, left: nil, bottom: infoView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 15, paddingRight: 0, width: 25, height: 25)
            okButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
            
            infoLabel.anchor(top: infoView.topAnchor, left: infoView.leftAnchor, bottom: okButton.topAnchor, right: infoView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
            
            UIView.animate(withDuration: 0.5) {
                self.infoView.alpha = 1
            }
            infoButtonTapped = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Vote to Ban Users"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "info_button"), style: .plain, target: self, action: #selector(infoTapped))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false 
        tableView.register(KickUserTableViewCell.self, forCellReuseIdentifier: "kickUserCellId")
        tableView.register(UnBanUserTableViewCell.self, forCellReuseIdentifier: "unbanUserCellId")
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(activityIndicator)
        activityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        retrieveListOfBannedUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.retrieveListOfUsers()
        }
        
        performOnboarding()
    
    }
    
    fileprivate func performOnboarding() {
        if (UserDefaults.standard.value(forKey: "seenBanGuide") as? Bool) != nil {
            // User has seen it already, do nothing
        } else {
            // User hasn't even seen it once
            UserDefaults.standard.set(true, forKey: "seenBanGuide")
            infoTapped()
        }
    }
    
    var listOfBannedUsers = [String]()
    
    fileprivate func retrieveListOfBannedUsers() {
        guard let conversationId = self.conversation?.conversationId else {return}
       
        activityIndicator.startAnimating()
        Database.database().reference().child("conversations_bannedUsers").child(conversationId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String:AnyObject] else {return}
            for (key, _) in dictionaries {
                self.listOfBannedUsers.append(key)
            }
            
        }
    }
    
    fileprivate func retrieveListOfUsers() {
        
        let ref = Database.database().reference()
        guard let conversationId = conversation?.conversationId else {return}
        ref.child("conversation_users").child(conversationId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String:AnyObject] else {return}
            
            for (key, _) in dictionaries {
                let userId = key
                
                Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let userDictionary = snapshot.value as? [String:Any] else {return}
                    
                    let user = User(uid: userId, dictionary: userDictionary)
                    
                    if self.listOfBannedUsers.contains(user.uid) {
                        self.bannedUsers.append(user)
                    } else {
                        self.users.append(user)
                    }
                    
                }, withCancel: nil)
                
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            })
            
        }, withCancel: nil)
    }
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
