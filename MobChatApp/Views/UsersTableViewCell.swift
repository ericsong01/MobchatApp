
import UIKit
import Firebase

class UsersTableViewCell: UITableViewCell, ReloadCollectionViewProtocol {
    
    func reloadCollectionView() {
        // collectionView.reloadSections(IndexSet(integer: 0))
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil) { (true) in
            print ("finished updating")
            self.activityIndicatorDelegate.stopActivityIndicator()
        }
    }
    
    weak var activityIndicatorDelegate: ActivityIndicatorProtocol!
    
    let cellId = "collectionViewCellId"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(collectionView)
        
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: (10/667) * UIScreen.main.bounds.height, paddingLeft: (10/375) * UIScreen.main.bounds.width, paddingBottom: (5/667) * UIScreen.main.bounds.height, paddingRight: (10/375) * UIScreen.main.bounds.width, width: 0, height: 0)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UsersCollectionView = {
       let collectionView = UsersCollectionView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
}

// Use this in the chatinfotableview controller so that the info is uploaded immediately to this collectionview from the VC and not the table view first
class UsersCollectionView: UICollectionView  {
   
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UserCollectionViewCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            
            guard let username = user?.username else {return}
            usernameTextView.text = username
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(profileImageView)
        if UIScreen.main.bounds.height < 667 {
            profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        } else {
            profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        }
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(usernameTextView)
        usernameTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        usernameTextView.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, bottom: bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: -5, paddingBottom: 3, paddingRight: -5, width: 0, height: 0)
        
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear 
        tv.isUserInteractionEnabled = false
        tv.isScrollEnabled = true
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return tv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
