import UIKit
import Firebase

protocol ProfileImageProtocol: class {
    func accessProfile(indexPath: IndexPath)
    func performZoomInForStartingImageView(startingImageView: UIImageView)
    func playMessageVideo(url: URL)
    func deleteVideoMessageForIndexPath(indexPath: IndexPath)
}

class ChatMessageCell: UICollectionViewCell {
    
    weak var delegate: ProfileImageProtocol!
    
    var videoUrl: String?
        
    let textView: UITextView = {
        let tv = UITextView()
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:))))
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.red
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func deleteTapped() {
        guard let superView = self.superview as? UICollectionView else {
            print("superview is not a collectionView - getIndexPath")
            return 
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        delegate?.deleteVideoMessageForIndexPath(indexPath: indexPath)
    }
    
    var deleteModeOn: Bool = false
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if deleteModeOn {
                deleteButton.isHidden = true
                deleteModeOn = false
            } else {
                deleteButton.isHidden = false
                deleteModeOn = true
            }
        }
    }
    
    @objc func handlePlay() {
        guard let videoUrl = self.videoUrl, let url = URL(string: videoUrl) else {return}
        delegate?.playMessageVideo(url: url)
    }
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false 
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.gray
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let nameLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.purple 
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        return iv
    }()
    
    @objc func profileImageTapped() {
        guard let superView = self.superview as? UICollectionView else {
            print("superview is not a UITableView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        delegate?.accessProfile(indexPath: indexPath)
    }
    
    let bubbleMessageView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var messageImageView: CustomImageView = {
        
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            delegate?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    var bubbleViewTopAnchor: NSLayoutConstraint?
    var bubbleViewNameAnchor: NSLayoutConstraint?
    var bubbleViewBottomAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleMessageView) // We made another view so that this is transformed and not the cell
        
        bubbleMessageView.addSubview(nameLabel)
        bubbleMessageView.addSubview(messageImageView)
        bubbleMessageView.addSubview(profileImageView)
        bubbleMessageView.addSubview(bubbleView)
        bubbleMessageView.addSubview(textView)
        bubbleMessageView.addSubview(playButton)
        bubbleMessageView.addSubview(deleteButton)
        
        bubbleMessageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        bubbleMessageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: bubbleMessageView.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
     
        nameLabel.anchor(top: bubbleMessageView.topAnchor, left: bubbleMessageView.leftAnchor, bottom: nil, right: bubbleMessageView.rightAnchor, paddingTop: 0, paddingLeft: 16 + 32 + 8, paddingBottom: 0, paddingRight: 16, width: 0, height: 20)
        
        bubbleViewTopAnchor = bubbleView.topAnchor.constraint(equalTo: bubbleMessageView.topAnchor)
        bubbleViewNameAnchor = bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor)
        bubbleViewTopAnchor?.isActive = false
        bubbleViewNameAnchor?.isActive = false
        
        bubbleViewBottomAnchor = bubbleView.bottomAnchor.constraint(equalTo: bubbleMessageView.bottomAnchor)
        bubbleViewBottomAnchor?.isActive = true
        
        // TODO: Fix delete button and make it only visible to creators 
        deleteButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 40)
        deleteButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        
        playButton.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        messageImageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        profileImageView.anchor(top: nil, left: bubbleMessageView.leftAnchor, bottom: bubbleView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 32, height: 32)
        
        textView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

