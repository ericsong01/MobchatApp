import UIKit
import Firebase

class VideoCell: UICollectionViewCell {
     
     var highlight: Highlight? {
          didSet {
               self.titleLabel.text = highlight?.title
               
               if let senderId = highlight?.senderId {
                    Database.fetchUsersWithUID(uid: senderId) { (user) in
                         self.creatorLabel.text = user.username
                    }
               }
               
               if let second = highlight?.timestamp?.doubleValue {
                    let timestampDate = Date(timeIntervalSince1970: second)
                    self.timeLabel.text = timestampDate.timeAgo(numericDates: false)
               }
               
               if let thumbnailImageUrl = highlight?.thumbnailImageUrl {
//                    self.imageView.loadImage(urlString: thumbnailImageUrl)
//                    if let height = imageView.image?.size.height, let width = imageView.image?.size.width {
//                         if height > width {
//                              imageView.contentMode = .scaleAspectFit
//                              imageView.backgroundColor = UIColor.black
//                         } else {
//                              imageView.contentMode = .scaleAspectFill
//                              imageView.backgroundColor = UIColor.clear
//                         }
//                    }
                    self.imageView.loadHighlightImage(urlString: thumbnailImageUrl, imageView: self.imageView)
               }
               
               if let videoUrl = highlight?.videoUrl, let videoTitle = highlight?.title, let highlightId = highlight?.highlightId {
                    self.videoUrl = videoUrl
                    self.videoTitle = videoTitle
                    self.highlightId = highlightId
               }

          }
     }
     
     let titleLabel: UILabel = {
          let label = UILabel()
          label.textAlignment = .center
          label.adjustsFontSizeToFitWidth = true
          label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
          return label
     }()
     
     var videoUrl: String?
     var videoTitle: String?
     var highlightId: String?
     
     weak var playHighLightDelegate: PlayHighlightProtocol! 
     
     let uploaderLabel: UILabel = {
        let label = UILabel()
          label.text = "Uploader:"
          label.textAlignment = .left
          label.font = UIFont.systemFont(ofSize: 12)
          return label
     }()
     
     let creatorLabel: UILabel = {
          let label = UILabel()
          label.textAlignment = .left
          label.font = UIFont.systemFont(ofSize: 12)
          return label
     }()
     
     let timeLabel: UILabel = {
          let label = UILabel()
          label.textAlignment = .left
          label.font = UIFont.systemFont(ofSize: 12)
          return label
     }()
     
     lazy var imageView: CustomImageView = {
          let iv = CustomImageView()
          iv.layer.cornerRadius = 5
          iv.layer.masksToBounds = true
          iv.clipsToBounds = true
          return iv
     }()
     
     lazy var playButton: UIButton = {
          let button = UIButton(type: .system)
          button.tintColor = UIColor.white
          button.imageView?.contentMode = .scaleAspectFit
          button.setImage(UIImage(named: "play"), for: .normal)
          button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
          return button
     }()
     
     @objc func playTapped() {
          guard let videoUrl = self.videoUrl else {return}
          playHighLightDelegate.playHighlight(url: videoUrl)
     }
     
     lazy var deleteButton: UIButton = {
          let button = UIButton()
          button.setImage(UIImage(named: "delete_video"), for: .normal)
          button.layer.masksToBounds = true
          button.clipsToBounds = true
          button.isHidden = true
          button.isEnabled = false 
          button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
          return button
     }()
     
     override init(frame: CGRect) {
          super.init(frame: frame)
          
          backgroundColor = UIColor(red: 0.0001, green: 0.0001, blue: 0.0001, alpha: 0.1)
          
          layer.borderColor = UIColor(red: 0, green: 0.7529, blue: 1, alpha: 1).cgColor
          
          layer.cornerRadius = 10
          
          layer.borderWidth = 1
          
          addSubview(titleLabel)
          titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 17)
          
          addSubview(uploaderLabel)
          uploaderLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 60, height: 16)
          
          addSubview(creatorLabel)
          creatorLabel.anchor(top: titleLabel.bottomAnchor, left: uploaderLabel.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 3, paddingLeft: 3, paddingBottom: 0, paddingRight: 5, width: 0, height: 16)
          
          addSubview(timeLabel)
          timeLabel.anchor(top: creatorLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 15)
          
          addSubview(imageView)
          imageView.anchor(top: timeLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
          
          addSubview(playButton)
          playButton.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
          
          addSubview(deleteButton)
          deleteButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 30, height: 30)
          deleteButton.layer.cornerRadius = 10
          
     }
     
     @objc func handleDelete() {
          guard let videoTitle = self.videoTitle, let highlightId = self.highlightId else {return}
          playHighLightDelegate.deleteHighlight(videoTitle: videoTitle, highlightId: highlightId)
     }
     
     required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
     }
     
}
