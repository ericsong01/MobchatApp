import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatLogBioViewController: UIViewController {
    
    var uid: String?
    
    var user: User?
    
    weak var popChatLogControllerDelegate: PopChatLogControllerProtocol!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.layer.borderColor = UIColor.purple.cgColor
        profileImageView.layer.borderWidth = 2 
    }
    
    var fromTableViewController: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(bioLabel)
        
        if fromTableViewController == false {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            profileImageView.layer.borderColor = UIColor.purple.cgColor
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "report_chat_button"), style: .plain, target: self, action: #selector(handleReportBlockUser))
        } else {
            view.addSubview(dismissButton)
            dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((10/667) * view.bounds.height), paddingLeft: (10/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            dismissButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 90/375).isActive = true
            dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 40/90).isActive = true
        }
        
        fetchUser()
        
        if fromTableViewController == false { // The user clicked on the profile pic in info VC
            profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: ((30/667) * view.bounds.height), paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        } else { // The user clicked on the profile pic in the chat log 
            profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: ((65/667) * view.bounds.height), paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 260/375).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        nameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (30/667) * view.bounds.height, paddingLeft: (30/375) * view.bounds.width, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        emailLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, paddingTop: (5/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bioLabel.anchor(top: emailLabel.bottomAnchor, left: emailLabel.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        
        if view.bounds.height < 667 {
            bioLabel.font = UIFont.systemFont(ofSize: 13)
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        } 
    }
    
    @objc func handleReportBlockUser() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let blockedUserUid = self.user?.uid else {return}
        
        alert.addAction(UIAlertAction(title: "Report \(user?.username ?? "User")", style: .default, handler: { (action) in
            let reportUserVC = ReportUserViewController()
            reportUserVC.user = self.user
            self.navigationController?.pushViewController(reportUserVC, animated: true)
        }))
        
        let blockUserAction = UIAlertAction(title: "Block \(user?.username ?? "User")", style: .default) { (action) in
            
            // Block the user --> Make it so their text is empty but the user profile image is still accessible so they can unblock the user
            let confirmBlockAlert = UIAlertController(title: "Block \(self.user?.username ?? "User")", message: "You will no longer be able to view their messages. They can still view yours though", preferredStyle: .alert)
            confirmBlockAlert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { (action) in
                
                print ("blocked bitch")
                let blockValue = [blockedUserUid:1]
        
                Database.database().reference().child("users_blocked").child(uid).updateChildValues(blockValue, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Failed to block user:", error)
                        return
                    }
                    listOfBlockedUsers.append(blockedUserUid)
            
                    self.popChatLogControllerDelegate.popChatLogController()
                    
                })
                
            }))
            
            confirmBlockAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                confirmBlockAlert.dismiss(animated: true, completion: nil)
            }))
            
            alert.dismiss(animated: true, completion: nil)
            self.present(confirmBlockAlert, animated: true, completion: nil)
            
        }
        
        
        let unblockUserAction = UIAlertAction(title: "Unblock \(user?.username ?? "User")", style: .default) { (action) in
            
            let unblockValue = [blockedUserUid:NSNull()]
            Database.database().reference().child("users_blocked").child(uid).updateChildValues(unblockValue, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print ("Failed to unblock user:", error)
                    return
                }
                
                listOfBlockedUsers.removeAll(where: {$0 == blockedUserUid})
                self.popChatLogControllerDelegate.popChatLogController()
                
            })
        }
        
        if listOfBlockedUsers.contains(blockedUserUid) {
            alert.addAction(unblockUserAction)
        } else {
           alert.addAction(blockUserAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var randomArrayOfFacts = ["'Do geese see God?' can be read forwards and backwards.", "A baby octopus is about the size of a flea when it is born.", "In Uganda, around 48% of the population is under 15 years of age.", "Recycling one glass jar saves enough energy to watch television for 3 hours.", "Approximately 10-20% of U.S. power outages are caused by squirrels.", "95% of people text things they could never say in person.", "If Pinocchio says 'My Nose Will Grow Now' it would cause a paradox.", "Polar bears can eat as many as 86 penguins in a single sitting.", "Billy goats urinate on their own heads to smell more attractive to females.", "During your lifetime, you will produce enough saliva to fill two swimmings pool."]

    fileprivate func fetchUser() {
        guard let uid = uid else {return}
        Database.fetchUsersWithUID(uid: uid) {[weak self] (user) in
            DispatchQueue.main.async {
                self?.user = user
                
                guard let profileImageUrl = user.profileImageUrl else {return}
                self?.profileImageView.loadImage(urlString: profileImageUrl)
                
                guard let bio = user.bio else {return}
                guard let username = user.username else {return}
                if bio == "" {
                    if let randomFact = self?.randomArrayOfFacts[Int(arc4random_uniform(UInt32(self?.randomArrayOfFacts.count ?? 1 - 1)))] {
                        self?.bioLabel.text = "Sorry, \(username) has not yet written a bio. Here's a random fact to make up for their laziness. \n\(randomFact)"
                    } else {
                        self?.bioLabel.text = "Sorry, \(username) has not yet written a bio."
                    }
                    self?.bioLabel.textColor = UIColor.darkGray
                } else {
                    self?.bioLabel.text = bio
                }
                
                guard let name = user.username else {return}
                if self?.fromTableViewController == false {
                    self?.navigationItem.title = name
                }
                self?.nameLabel.text = name
            }
        }
    }
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.isUserInteractionEnabled = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
}
