import UIKit
import FirebaseDatabase
import FirebaseAuth
import SafariServices

extension Database {
    
    static func fetchUsersWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String:Any] else {return}

            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (error) in
            print ("Failed to fetch user for posts:", error)
        }
    }
}

class UserProfileController: UIViewController, UITextFieldDelegate {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
    }
    
    var user: User?
    
    var username: String?
    
    var profileImageUrl: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailLabel.text = globalEmail
        nameLabel.text = globalUsername
        bioTextView.text = globalBiography
        navigationItem.title = globalUsername
        guard let profileImageUrl = globalProfileImageUrl else {return}
        profileImageView.loadImage(urlString: profileImageUrl)
        
        if globalBiography == nil || globalBiography == "" {
            bioTextView.textColor = UIColor.darkGray
            bioTextView.text = "Children diagnosed with Cystic Fibrosis (a terminal and progressive disease) spend nearly a quarter of their lives in the hospital. Press Settings > Read Me to find out more. Also, write a bio."
        } else {
            bioTextView.textColor = UIColor.black
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.masksToBounds = true 
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(editProfileSelected), for: .touchUpInside)
        button.setTitle("Edit Profile", for: .normal)
        return button
    }()
    
    @objc func editProfileSelected() {
        let editProfileController = EditUserProfileController()
        let navController = UINavigationController(rootViewController: editProfileController)
        editProfileController.userProfileVC = self
        present(navController, animated: true, completion: nil)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let bioTextView: UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear 
        tv.isEditable = false
        tv.contentInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
       
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)

       fetchUser()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettingsTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "announcement_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(announcementsTapped))
        
        configureLayout()
        
    }
    
    @objc func announcementsTapped() {
        let announcementsVC = AnnouncementsViewController()
        let navController = UINavigationController(rootViewController: announcementsVC)
        self.present(navController, animated: true, completion: nil)
    }
        
    fileprivate func configureLayout() {
        view.addSubview(profileImageView)
        view.addSubview(editProfileButton)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(bioTextView)
        
        if view.bounds.height == 896 {
            profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: ((43/667) * view.bounds.height), paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        } else {
             profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: ((30/667) * view.bounds.height), paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 240/375).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        
        editProfileButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        editProfileButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 150/375).isActive = true
        editProfileButton.heightAnchor.constraint(equalTo: editProfileButton.widthAnchor, multiplier: 1/5).isActive = true
        editProfileButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        nameLabel.anchor(top: editProfileButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (20/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30/375 * (view.bounds.width)).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30/375 * (view.bounds.width)).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 30/667).isActive = true
        
        emailLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, paddingTop: (5/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emailLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 20/667).isActive = true
        
        bioTextView.anchor(top: emailLabel.bottomAnchor, left: emailLabel.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: -2, paddingBottom: (10/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        bioTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 315/375).isActive = true
        
        if view.bounds.height < 667 {
            bioTextView.font = UIFont.systemFont(ofSize: 13)
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            emailLabel.font = UIFont.systemFont(ofSize: 12)
        } else if view.bounds.height == 812 {
            bioTextView.font = UIFont.systemFont(ofSize: 17)
            nameLabel.font = UIFont.boldSystemFont(ofSize: 21)
            emailLabel.font = UIFont.systemFont(ofSize: 14)
        } else if view.bounds.height == 896 {
            bioTextView.font = UIFont.systemFont(ofSize: 18)
            nameLabel.font = UIFont.boldSystemFont(ofSize: 21)
            emailLabel.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.fetchUsersWithUID(uid: uid) {[weak self] (user) in
            
            DispatchQueue.main.async {
                self?.user = user
                
                self?.username = self?.user?.username
                globalUsername = self?.username
                self?.navigationItem.title = self?.username
                
                guard let profileImageUrl = user.profileImageUrl else {return}
                globalProfileImageUrl = profileImageUrl
                self?.profileImageView.loadImage(urlString: profileImageUrl)
                
                self?.nameLabel.text = user.username
                globalEmail = Auth.auth().currentUser?.email
                self?.emailLabel.text = globalEmail
                
                if user.bio == nil || user.bio == "" {
                    self?.bioTextView.text = "Children diagnosed with Cystic Fibrosis (a terminal and progressive disease) spend nearly a quarter of their lives in the hospital. Press Settings > Read Me to find out more. Also, write a bio."
                    self?.bioTextView.textColor = UIColor.darkGray
                } else {
                    globalBiography = user.bio
                    self?.bioTextView.text = globalBiography
                }
            }
        }
    }
    
    @objc func handleSettingsTapped() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Read Me!", style: .default, handler: { (action) in
            let tributeVC = TributeViewController()
            self.present(tributeVC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Privacy Policy", style: .default, handler: { (action) in
            let privacyPolicyVC = PrivacyPolicyViewController()
            self.present(privacyPolicyVC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            guard let username = globalUsername else {return}
        
            let ref = Database.database().reference()
            
            let alertController = UIAlertController(title: "Log out of \(username)?", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            alertController.preferredAction = cancelAction
            
            let logoutAction = UIAlertAction(title: "Log Out", style: .default) { (action) in
           
                    // We delete the fcmToken upon log out so the user doesn't receive push notifications
                // Now test if we receive push notifications signed in as the other user
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                ref.child("users").child(uid).child("conversations_notifications_active").removeValue(completionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Couldn't delete notifications section:", error)
                        return
                    }
                    
                    do {
                        
                        ref.removeAllObservers() // Removes all observers in the database
                        
                        globalEmail = nil
                        globalUsername = nil
                        globalBiography = nil
                        listOfBlockedUsers.removeAll()
                        bannedConversations.removeAll()
                        numberOfDeletes = 0 
                        
                        try Auth.auth().signOut()
                        
                        let openingScreenVC = OpeningScreenViewController()
                        let navController = UINavigationController(rootViewController: openingScreenVC)
                        self.present(navController, animated: true, completion: nil)
                        return
                        
                    } catch {
                        print ("Failed to sign out")
                    }
                })
                
                self.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(logoutAction)
            self.present(alertController, animated: true, completion: nil)
        }))
        
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        
    }
    
}
