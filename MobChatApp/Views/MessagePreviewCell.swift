
import UIKit
import Firebase

class MessagePreviewCell: UITableViewCell {
    
    var conversation: Conversation? {
        didSet {
            
            guard let imageUrl = conversation?.imageUrl else {return}
            convoImageView.loadImage(urlString: imageUrl)

            convoNameLabel.text = conversation?.conversationName
            
        }
    }
    
    var activeUserCount: Int? 
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        selectionStyle = .none
        
        addSubview(shadowLayer)
        addSubview(mainBackgroundView)
        
        mainBackgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 10, paddingRight: 5, width: 0, height: 0)
        shadowLayer.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 10, paddingRight: 5, width: 0, height: 0)
                
        addSubview(convoImageView)
        
        convoImageView.anchor(top: mainBackgroundView.topAnchor, left: mainBackgroundView.leftAnchor, bottom: mainBackgroundView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 8, paddingBottom: 10, paddingRight: 0, width: 70, height: 0)
        
        addSubview(convoNameLabel)
        convoNameLabel.centerYAnchor.constraint(equalTo: convoImageView.centerYAnchor).isActive = true
        convoNameLabel.anchor(top: mainBackgroundView.topAnchor, left: convoImageView.rightAnchor, bottom: mainBackgroundView.bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: 5, paddingRight: (10/375) * UIScreen.main.bounds.width, width: 0, height: 0)
       
        addSubview(activeStateImage)
        addSubview(userCountImage)
        addSubview(activeUserCountLabel)
        
        activeUserCountLabel.anchor(top: nil, left: nil, bottom: mainBackgroundView.bottomAnchor, right: mainBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: 20, height: 20)
        
        userCountImage.anchor(top: nil, left: nil, bottom: nil, right: activeUserCountLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 3, width: 15, height: 15)
        userCountImage.centerYAnchor.constraint(equalTo: activeUserCountLabel.centerYAnchor).isActive = true
        
        activeStateImage.anchor(top: nil, left: nil, bottom: nil, right: userCountImage.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: 10, height: 10)
        activeStateImage.centerYAnchor.constraint(equalTo: userCountImage.centerYAnchor).isActive = true 
        
    }
    
    let mainBackgroundView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
        return view
    }()
    
    let shadowLayer: ShadowView = {
       let view = ShadowView()
        view.layer.masksToBounds = false
        return view
    }()
    
    let convoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    let convoNameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true 
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    let activeUserCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.text = "0"
        label.textAlignment = .left
        return label
    }()
    
    let userCountImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "active_user_icon")?.withRenderingMode(.alwaysOriginal)
        return iv
    }()
    
    let activeStateImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "active_state_icon")
        iv.tintColor = UIColor.green
        iv.isHidden = true
        return iv
    }()

    @objc func handleLeaveChat() {
        print ("handle leave chat")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
