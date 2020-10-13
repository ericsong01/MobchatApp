import UIKit
import Firebase

class AddVideoCell: UICollectionViewCell {
    
    let addVideoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add_video"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.backgroundColor = UIColor(red: 0.0001, green: 0.0001, blue: 0.0001, alpha: 0.1)
        button.layer.borderColor = UIColor(red: 0.1961, green: 0.6549, blue: 1, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        button.layer.cornerRadius = 15
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(addVideoButton)
        addVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addVideoButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addVideoButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.bounds.width, height: self.bounds.height)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
