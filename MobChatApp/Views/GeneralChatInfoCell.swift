
import UIKit

class GeneralChatInfoCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorProfileImage.layer.cornerRadius = creatorProfileImage.bounds.height / 2
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear 
        
        addSubview(chatDescriptionTextView)
        chatDescriptionTextView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 7, paddingLeft: 13, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        addSubview(creatorTitleLabel)
        creatorTitleLabel.anchor(top: chatDescriptionTextView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 13, paddingBottom: 0, paddingRight: 0, width: 70, height: 23)
        
        addSubview(creatorProfileImage)
        creatorProfileImage.anchor(top: chatDescriptionTextView.bottomAnchor, left: creatorTitleLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        addSubview(creatorLabel)
        creatorLabel.anchor(top: creatorProfileImage.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 85, height: 23)
        creatorLabel.centerXAnchor.constraint(equalTo: creatorProfileImage.centerXAnchor).isActive = true
        
        addSubview(timestampTitleLabel)
        timestampTitleLabel.anchor(top: creatorLabel.bottomAnchor, left: creatorTitleLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 170, height: 23)
        addSubview(timestampLabel)
        timestampLabel.anchor(top: nil, left: timestampTitleLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 23)
        timestampLabel.centerYAnchor.constraint(equalTo: timestampTitleLabel.centerYAnchor).isActive = true
        
        addSubview(membersLabel)
        membersLabel.anchor(top: timestampLabel.bottomAnchor, left: timestampTitleLabel.leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 100, height: 23)
    }

    let chatDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .darkGray 
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.isEditable = false
        return tv
    }()

    let creatorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Creator:"
        //label.backgroundColor = UIColor.blue
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let creatorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center 
        //label.backgroundColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let creatorProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let timestampTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Establishment Date:"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let membersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
