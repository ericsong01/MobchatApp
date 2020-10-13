import UIKit

class ConvoSearchCell: UICollectionViewCell {
    
    var conversation: Conversation? {
        didSet {
            
            guard let conversationName = conversation?.conversationName else {return}
            convoNameLabel.text = conversationName

            guard let numberOfMembers = conversation?.numberOfMembers else {return}
            memberLabel.text = "\(numberOfMembers)"
            
            guard let chatDescription = conversation?.chatDescription else {return}
            descriptionLabel.text = chatDescription
            
            if let second = conversation?.lastMessageTime?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: second)
                messageTime.text = timestampDate.timeAgo(numericDates: false)
            }
            
            guard let imageUrl = conversation?.imageUrl else {return}
            imageView.loadImage(urlString: imageUrl)
            
        }
    }
    
    let convoNameLabel: UILabel = {
       let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let messageTime: UILabel = {
       let label = UILabel()
        label.textAlignment = .right 
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let memberImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "user_count")
        return iv
    }()
    
    let memberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "100"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(imageView)
        addSubview(convoNameLabel)
        addSubview(descriptionLabel)
        addSubview(messageTime)
        addSubview(memberLabel)
        addSubview(memberImage)
        
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.layer.cornerRadius = 24
        imageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        
        convoNameLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: messageTime.leftAnchor, paddingTop: 10, paddingLeft: 8, paddingBottom: 0, paddingRight: 4, width: 0, height: 25)
        
        descriptionLabel.anchor(top: convoNameLabel.bottomAnchor, left: convoNameLabel.leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 3, paddingRight: 0, width: 250, height: 0)
        
        messageTime.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 70, height: 25)
        
        memberLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 25, height: 25)
        memberLabel.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
        
        memberImage.anchor(top: nil, left: nil, bottom: nil, right: memberLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: 15, height: 15)
        memberImage.centerYAnchor.constraint(equalTo: memberLabel.centerYAnchor).isActive = true 
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

