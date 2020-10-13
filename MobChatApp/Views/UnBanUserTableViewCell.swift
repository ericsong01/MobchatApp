
import UIKit

class UnBanUserTableViewCell: UITableViewCell {
    
    weak var kickUserDelegate: KickUserVoteProtocol!
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            
            guard let username = user?.username else {return}
            usernameLabel.text = username
        }
    }
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var unbanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "unban_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleUnBan), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUnBan() {
        print ("kicked")
        guard let uid = self.user?.uid, let username = self.user?.username else {return}
        kickUserDelegate.voteToUnBanUser(uid: uid, username: username)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(usernameLabel)
        usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 60, width: 0, height: 30)
        
        addSubview(unbanButton)
        unbanButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 35, height: 35)
        unbanButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
