import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class AddVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var conversationId: String?
    var isMemberOfChat: Bool?
    
    override func viewDidAppear(_ animated: Bool) {
        // Animate the dim view in
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0.5
            self.lightView.alpha = 1
        }, completion: nil)
    }
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.alpha = 0
        return view
    }()
    
    let lightView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Highlight Title"
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.leftView = spacerView
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1).cgColor
        tf.tintColor = .black
        return tf
    }()
    
    lazy var addVideoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add_video"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor(red: 0.0001, green: 0.0001, blue: 0.0001, alpha: 0.1)
        button.layer.borderColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(addVideoButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(addVideoButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(addVideoButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(addVideoButtonTouchDragExit), for: .touchDragExit)
        return button
    }()
    
    @objc func addVideoButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.addVideoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func addVideoButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.addVideoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func addVideoButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.addVideoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    @objc func addVideoButtonTapped() {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.addVideoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.addVideoButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                imagePickerController.mediaTypes = [kUTTypeMovie as String]
                imagePickerController.modalPresentationStyle = .overCurrentContext
                imagePickerController.modalTransitionStyle = .coverVertical
                let chatLogController = ChatLogController()
                chatLogController.resignFirstResponder()
                self.present(imagePickerController, animated: true, completion: nil)
            })
        }
        
    }
    
    var videoUrl: URL?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: videoUrl) {
                addVideoButton.backgroundColor = UIColor.black
                self.videoUrl = videoUrl
                addVideoButton.setImage(thumbnailImage, for: .normal)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Generate a thumbnail image
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        
        // Provide an asset for the video
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print (error)
        }
        
        // Make return type an optional
        return nil
        
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.red.cgColor
        button.tintColor = UIColor.red
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    @objc func cancelTapped() {
        dismissView()
    }
    
    lazy var doneButton: UIButton = {
       let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1)
.cgColor
        button.tintColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1)
        button.setTitle("Upload", for: .normal)
        return button
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.trackTintColor = UIColor.clear
        pv.progressTintColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1)
        return pv
    }()
    
    let highlightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "\u{1F4FA} Upload Highlight \u{1F4FA}"
        label.textColor = UIColor(red: 0.1922, green: 0.6588, blue: 1, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    @objc func uploadTapped() {
        
        if isMemberOfChat ?? false {
            // Do nothing, uploader is a member
        } else {
            // Stop the upload
            self.presentNotMemberAlert()
            return
        }

        guard let conversationId = self.conversationId, let highlightTitle = titleTextField.text, let videoUrl = self.videoUrl, let thumbnailImage = addVideoButton.imageView?.image  else {
            presentAlert(alert: "All fields must be filled")
            return
        }
        
        if highlightTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            presentAlert(alert: "All fields must be filled")
            return
        }
        
        let model = Nudity()
        let inputImageSize: CGFloat = 224.0
        let minLen = min(thumbnailImage.size.width, thumbnailImage.size.height)
        let resizedImage = thumbnailImage.resize(to: CGSize(width: inputImageSize * thumbnailImage.size.width / minLen, height: inputImageSize * thumbnailImage.size.height / minLen))
        let cropedToSquareImage = resizedImage.cropToSquare()
        
        guard let pixelBuffer = cropedToSquareImage?.pixelBuffer() else {
            fatalError("Pixel buffer creation failed")
        }
        
        guard let result = try? model.prediction(data: pixelBuffer) else {
            fatalError("Prediction failed!")
        }
        
        let confidence = result.prob["\(result.classLabel)"]! * 100.0
        print (result.classLabel, confidence)
        let possiblyNudity = result.classLabel.contains("SFW") && confidence <= 70
        if result.classLabel.contains("NSFW") || possiblyNudity {
            if result.classLabel.contains("NSFW") && confidence >= 90 {
                // Upload this to the log
                guard let username = globalUsername else {return}
                guard let logKey = Database.database().reference().child("highlights_log").child(conversationId).childByAutoId().key, let uid = Auth.auth().currentUser?.uid else {return}
                let log = [uid: "Naughty \(username) attempted to upload a NFSW video \u{1F47F}"]
                
                let values = ["/highlights_log/\(conversationId)/\(logKey)":log] as [String : Any]
                Database.database().reference().updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Couldn't update highlights log:", error)
                    }
                    
                })
            }
            self.presentNudityAlert(alert: "Your video has a \(Int(confidence))% chance of being \(result.classLabel).")
            return
        } else {
            
            UIView.animate(withDuration: 0.2) {
                self.uploadingLabel.isHidden = false
            }
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let ref = Storage.storage().reference().child("conversation_highlights").child(conversationId).child(highlightTitle)
            let uploadTask = ref.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
                
                if let error = error {
                    print ("Couldn't upload video:", error)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print ("Failed to retrieve download url", error as Any)
                        UIApplication.shared.endIgnoringInteractionEvents()
                        return
                    }
                    
                    if let videoUrl = url?.absoluteString {
                        self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                            
                            let databaseRef = Database.database().reference().child("conversations_highlights").child(conversationId)
                            let childRef = databaseRef.childByAutoId()
                            let highlightId = childRef.key
                            
                            guard let senderId = Auth.auth().currentUser?.uid else {return}
                            let timestamp = NSDate().timeIntervalSince1970
                            
                            let values: [String:AnyObject] = ["senderId":senderId, "timestamp":timestamp, "thumbnailImageUrl": imageUrl, "videoUrl": videoUrl, "title":highlightTitle, "highlightId":highlightId as Any] as [String:AnyObject]
                            
                            childRef.updateChildValues(values
                                , withCompletionBlock: { (error, ref) in
                                    
                                    if error != nil {
                                        print ("Couldn't upload video url to database:", error as Any)
                                        return
                                    }
                                    
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    
                            })
                            
                        })
                    }
                    
                })
                
            }
            
            uploadTask.observe(.progress) { (snapshot) in
                
                guard let completedUnits = snapshot.progress?.fractionCompleted else {return}
                self.progressView.progress = Float( completedUnits)
                
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                if let username = globalUsername {
                    
                    guard let logKey = Database.database().reference().child("highlights_log").child(conversationId).childByAutoId().key, let uid = Auth.auth().currentUser?.uid else {return}
                    let log = [uid: "\(username) uploaded '\(highlightTitle)' to highlights \u{1F4FA}"]
                    
                    let values = ["/highlights_log/\(conversationId)/\(logKey)":log] as [String : Any]
                    Database.database().reference().updateChildValues(values, withCompletionBlock: { (error, ref) in
                        
                        if let error = error {
                            print ("Couldn't update highlights log:", error)
                        }
                        
                        UIView.animate(withDuration: 0.2) {
                            self.uploadingLabel.isHidden = true
                        }
                        self.dismissView()
                        
                    })
                } else { // If global username doesn't exist, we can't update the log, but we should dismiss the view
                    UIView.animate(withDuration: 0.2) {
                        self.uploadingLabel.isHidden = true
                    }
                    self.dismissView()
                }
                
            }
            
        }
     
    }
    
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        guard let conversationId = self.conversationId, let videoTitle = titleTextField.text else {return}
        let ref = Storage.storage().reference().child("conversationHighlights_imageThumbnails").child(conversationId).child(videoTitle)
        
        // Convert image into upload data w/ a compression of 0.2
        if let uploadData = image.jpegData(compressionQuality: 0.3) {
            
            // Put the image in the database
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print ("Failed to upload image:", error as Any)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print ("Couldn't get download url:", error as Any)
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString {
                        
                        completion(imageUrl)
                        
                        
                    }
                })
                
            }
        }
    }
    
    override func viewDidLoad() {
        
        view.addSubview(dimView)
        dimView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(lightView)
        lightView.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: (280/667) * view.bounds.height, paddingRight: 0, width: 0, height: 325)
        lightView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lightView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/375).isActive = true
        lightView.backgroundColor = UIColor.white

        lightView.addSubview(highlightLabel)
        highlightLabel.anchor(top: lightView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 30)
        highlightLabel.centerXAnchor.constraint(equalTo: lightView.centerXAnchor).isActive = true
        
        lightView.addSubview(titleTextField)
        titleTextField.anchor(top: highlightLabel.bottomAnchor, left: lightView.leftAnchor, bottom: nil, right: lightView.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40)
        
        lightView.addSubview(addVideoButton)
        addVideoButton.anchor(top: titleTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 130)
        addVideoButton.centerXAnchor.constraint(equalTo: lightView.centerXAnchor).isActive = true
        
        lightView.addSubview(doneButton)
        doneButton.anchor(top: addVideoButton.bottomAnchor, left: lightView.centerXAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 80, height: 40)
        
        lightView.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: nil, right: lightView.centerXAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 80, height: 40)
        cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        
        lightView.addSubview(progressView)
        progressView.anchor(top: nil, left: lightView.leftAnchor, bottom: lightView.bottomAnchor, right: lightView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 3)
        
        lightView.addSubview(uploadingLabel)
        uploadingLabel.anchor(top: nil, left: lightView.leftAnchor, bottom: progressView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 3, paddingRight: 0, width: 100, height: 20)
        
        titleTextField.delegate = self
        
    }
    
    let uploadingLabel: UILabel = {
       let label = UILabel()
        label.text = "Uploading..."
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    func dismissView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
            self.lightView.alpha = 0
        }) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Alert function
    func presentAlert(alert:String) {
        let alertVC = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == titleTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 30 //
        }
        return true
    }
        
        
        func presentNudityAlert(alert:String) {
            
            let alertVC = UIAlertController(title: "Potential Nudity Detected", message: alert, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                alertVC.dismiss(animated: true, completion: nil)
                
            }
            
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
            
        }
    
    func presentNotMemberAlert() {
        
        let alertVC = UIAlertController(title: "Oops!", message: "Join the chat to upload highlights", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            alertVC.dismiss(animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
}
