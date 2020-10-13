import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds
import UIFloatLabelTextField

class CreateNewConvoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonHasBeenTapped = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var createButtonBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.navigationBar.transparentNavigationBar()
        
        view.layer.configureGradientBackground(UIColor(red: 0.4314, green: 0.9843, blue: 0.8314, alpha: 1).cgColor,UIColor(red: 0, green: 0.6314, blue: 1, alpha: 1).cgColor)
        
        navigationItem.title = "Create a Chat"
        
        convoNameTextField.delegate = self
        descriptionTextField.delegate = self
        introDescriptionTextView.delegate = self 
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .purple
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]

        view.addSubview(createConvoButton)
        createConvoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createConvoButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (20/667) * view.bounds.height, paddingLeft: (25/375) * view.bounds.width, paddingBottom: 0, paddingRight: (25/375) * view.bounds.width, width: 0, height: 0)
        createConvoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            createButtonBottomAnchor = createConvoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((45/667) * view.bounds.height))
            createButtonBottomAnchor?.isActive = true
        } else if UIScreen.main.bounds.height == 896 {
            createButtonBottomAnchor = createConvoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((65/667) * view.bounds.height))
            createButtonBottomAnchor?.isActive = true
        } else {
            createButtonBottomAnchor = createConvoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((25/667) * view.bounds.height))
            createButtonBottomAnchor?.isActive = true
        }
        
        view.addSubview(introDescriptionTextView)
        introDescriptionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        introDescriptionTextView.anchor(top: nil, left: createConvoButton.leftAnchor, bottom: createConvoButton.topAnchor, right: createConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (25/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(descriptionCharacterCountLabel)
        descriptionCharacterCountLabel.anchor(top: nil, left: nil, bottom: introDescriptionTextView.topAnchor, right: introDescriptionTextView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (5/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        descriptionCharacterCountLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 20/667).isActive = true
        descriptionCharacterCountLabel.widthAnchor.constraint(equalTo: descriptionCharacterCountLabel.heightAnchor, multiplier: 1).isActive = true
        
        view.addSubview(descriptionTextField)
        descriptionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextField.anchor(top: nil, left: createConvoButton.leftAnchor, bottom: descriptionCharacterCountLabel.topAnchor, right: createConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (3/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        
        // This resizes the description text field, name text field, description text field
        if UIScreen.main.bounds.height >= 812 { // For iphoneXs
            descriptionTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 105).isActive = true
        } else if UIScreen.main.bounds.height == 568 {
            descriptionTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 45/667).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        } else {
            descriptionTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }

        view.addSubview(nameCharacterCountLabel)
        nameCharacterCountLabel.anchor(top: nil, left: nil, bottom: descriptionTextField.topAnchor, right: descriptionTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (5/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        nameCharacterCountLabel.heightAnchor.constraint(equalTo: descriptionCharacterCountLabel.heightAnchor).isActive = true
        nameCharacterCountLabel.widthAnchor.constraint(equalTo: nameCharacterCountLabel.heightAnchor, multiplier: 1).isActive = true
        
        view.addSubview(convoNameTextField)
        convoNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        convoNameTextField.anchor(top: nil, left: createConvoButton.leftAnchor, bottom: nameCharacterCountLabel.topAnchor, right: createConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (3/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        convoNameTextField.heightAnchor.constraint(equalTo: descriptionTextField.heightAnchor, multiplier: 1).isActive = true
        
        view.addSubview(partyLabel)
        partyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        partyLabel.anchor(top: nil, left: nil, bottom: convoNameTextField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: (15/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        partyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 200/375).isActive = true
        partyLabel.heightAnchor.constraint(equalTo: partyLabel.widthAnchor, multiplier: 25/100).isActive = true
        
        view.addSubview(addImageButton)
        addImageButton.anchor(top: nil, left: nil, bottom: partyLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: (0/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        addImageButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 170/667).isActive = true
        addImageButton.widthAnchor.constraint(equalTo: addImageButton.heightAnchor, multiplier: 1).isActive = true
        addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if UIScreen.main.bounds.height >= 736 { // iphone 6+, 6s+, 7+, 8+
            convoNameTextField.font = UIFont.systemFont(ofSize: 17)
            descriptionTextField.font = UIFont.systemFont(ofSize: 17)
            introDescriptionTextView.font = UIFont.systemFont(ofSize: 17)
        } else if UIScreen.main.bounds.height == 568 { // iphone5s, SE
            convoNameTextField.font = UIFont.systemFont(ofSize: 13)
            descriptionTextField.font = UIFont.systemFont(ofSize: 13)
            descriptionCharacterCountLabel.font = UIFont.systemFont(ofSize: 13)
            nameCharacterCountLabel.font = UIFont.systemFont(ofSize: 13)
            partyLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    let partyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.purple
        label.text = "Chat Picture \n (Darker Images Preferred)"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        return label
    }()
    
    let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage((UIImage(named: "plus_photo")), for: .normal)
        button.tintColor = UIColor.purple
        button.imageView?.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(handleConvoImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleConvoImageButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            addImageButton.imageView?.contentMode = .scaleAspectFill
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            addImageButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            addImageButton.imageView?.contentMode = .scaleAspectFill
            
        }
        
        addImageButton.layer.cornerRadius = addImageButton.frame.width / 2
        addImageButton.layer.masksToBounds = true
        addImageButton.layer.borderColor = UIColor.purple.cgColor
        addImageButton.layer.borderWidth = 1
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var convoNameTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.tag = 0
        tf.tintColor = .black
        tf.placeholder = "Chat Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) // Makes tf a complete black w/ low alpha value --> light gray
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.delegate = self
        return tf
    }()
    
    lazy var descriptionTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.tag = 1
        tf.tintColor = .black
        tf.placeholder = "Display Description / First Message"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.delegate = self
        return tf
    }()
    
    let descriptionCharacterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.purple
        return label
    }()
    
    let nameCharacterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "30"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.purple
        return label
    }()
    
    let introDescriptionTextView: DescriptionTextView = {
        let tv = DescriptionTextView()
        tv.contentInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        tv.tintColor = .black
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.isScrollEnabled = true
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.textContainer.maximumNumberOfLines = 15
        tv.layer.borderColor = UIColor.purple.cgColor
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 5
        return tv
    }()
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        let numberOfChars = newText.count
        return numberOfChars <= 400 && linesAfterChange <= textView.textContainer.maximumNumberOfLines

    }
    
    let createConvoButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.textColor = UIColor.black
        button.setTitle("Create Chat", for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(handleCreateButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleCreateButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(handleCreateButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(handleCreateButtonTouchDragExit), for: .touchDragExit)
        return button
    }()
    
    @objc func handleCreateButtonTouchDown() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.createConvoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func handleCreateButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.createConvoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func handleCreateButtonTouchDragExit() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.createConvoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    var buttonHasBeenTapped = false
    
    let listOfSwearWords = ["anus", "ass", "dick", "penis", "fuck", "shit", "bitch", "cock", "cunt", "whore", "pussy"]
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        return swearWords
            .reduce(false) { $0 || text.lowercased().contains($1) }
    }
    
    @objc func handleCreateButtonTapped() {
        
        guard buttonHasBeenTapped != true else {return} // Prevent multiple database registers
        
        self.buttonHasBeenTapped = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.createConvoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            self.createConvoButton.showLoading()
            UIView.animate(withDuration: 0.5, animations: {
                self.createConvoButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                guard let image = self.addImageButton.imageView?.image else {
                    self.createConvoButton.hideLoading()
                    return
                }
                guard let uploadData = image.jpegData(compressionQuality: 0.5) else {
                    self.createConvoButton.hideLoading()
                    return
                }
                guard let conversationName = self.convoNameTextField.text, let description = self.descriptionTextField.text, let chatIntroDescription = self.introDescriptionTextView.text else {
                    self.createConvoButton.hideLoading()
                    return
                }
            
                if !conversationName.trimmingCharacters(in: .whitespaces).isEmpty && !chatIntroDescription.trimmingCharacters(in: .whitespaces).isEmpty && !description.trimmingCharacters(in: .whitespaces).isEmpty && self.addImageButton.imageView?.image != UIImage(named: "plus_photo") {
                    
                    // Check for bad language
                    if self.containsSwearWord(text: conversationName, swearWords: self.listOfSwearWords) {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.createConvoButton.transform = CGAffineTransform.identity
                        }, completion: { (_) in
                            self.createConvoButton.hideLoading()
                            self.presentAlert(alert: "Check your language")
                            self.buttonHasBeenTapped = false
                            return
                        })
                    }
                    if self.containsSwearWord(text: description, swearWords: self.listOfSwearWords) {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.createConvoButton.transform = CGAffineTransform.identity
                        }, completion: { (_) in
                            self.createConvoButton.hideLoading()
                            self.presentAlert(alert: "Check your language")
                            self.buttonHasBeenTapped = false
                            return
                        })
                    }
                    if self.containsSwearWord(text: chatIntroDescription, swearWords: self.listOfSwearWords) {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.createConvoButton.transform = CGAffineTransform.identity
                        }, completion: { (_) in
                            self.createConvoButton.hideLoading()
                            self.presentAlert(alert: "Check your language")
                            self.buttonHasBeenTapped = false
                            return
                        })
                    }
                    
                    guard let conversationId = Database.database().reference().child("conversations").childByAutoId().key else {return}
                    
                    let storageRef = Storage.storage().reference().child("convo_images").child(conversationId)
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        
                        if let error = error {
                            print ("Failed to upload convo image to storage:", error)
                            UIView.animate(withDuration: 0.5, animations: {
                                self.createConvoButton.transform = CGAffineTransform.identity
                            }, completion: nil)
                            self.createConvoButton.hideLoading()
                            self.buttonHasBeenTapped = false
                            return
                        }
                        
                        storageRef.downloadURL(completion: { (url, error) in
                            
                            if error != nil {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.createConvoButton.transform = CGAffineTransform.identity
                                }, completion: nil)
                                self.createConvoButton.hideLoading()
                                self.buttonHasBeenTapped = false
                                return
                            }
                            
                            guard let convoImageUrl = url?.absoluteString else {return}
                            guard let uid = Auth.auth().currentUser?.uid else {return}
                            let messageTimestamp = NSDate().timeIntervalSince1970
                            let chatTimestamp = NSDate().timeIntervalSince1970
                            let messageValues : [String:AnyObject] = ["text":description as AnyObject, "senderId":uid as AnyObject, "timestamp": messageTimestamp as AnyObject]
                            guard let messageKey = Database.database().reference().child("conversation_users").child(conversationId).childByAutoId().key else {return}
                            
                            let convoValues : [String : AnyObject] = ["conversationId":conversationId as AnyObject, "conversationImageUrl": convoImageUrl as AnyObject, "conversationName": conversationName as AnyObject, "lastMessageTime": messageTimestamp as AnyObject, "description": description as AnyObject, "chatTimestamp": chatTimestamp as AnyObject, "creatorId":uid as AnyObject, "chatIntroDescription": chatIntroDescription as AnyObject]
                            
                            let childUpdates = ["/conversations/\(conversationId)":convoValues,"/users/\(uid)/conversations/\(conversationId)":1, "/conversation_users/\(conversationId)/\(uid)":1, "/conversation_messages/\(conversationId)/\(messageKey)":messageValues, "/users/\(uid)/conversations_notifications_active/\(conversationId)":1] as [String : Any]
                            
                            Database.database().reference().updateChildValues(childUpdates) { (error, ref) in
                                
                                if let error = error {
                                    print ("Failed to upload conversation data:", error)
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.createConvoButton.transform = CGAffineTransform.identity
                                    }, completion: nil)
                                    self.createConvoButton.hideLoading()
                                    self.buttonHasBeenTapped = false
                                    return
                                }
                                
                                self.createConvoButton.hideLoading()
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    }
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.createConvoButton.transform = CGAffineTransform.identity
                    }, completion: { (_) in
                        self.createConvoButton.hideLoading()
                        self.presentAlert(alert: "All fields (including chat picture) must be filled in")
                        self.buttonHasBeenTapped = false
                    })
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if let text = textField.text {
            let newLength = text.count + string.count - range.length
            
            if textField == descriptionTextField {
                if newLength <= 50 {
                    descriptionCharacterCountLabel.text =  "\(50 - newLength)"
                    return newLength <= 50
                }
            } else if textField == convoNameTextField {
                if newLength <= 30 {
                    nameCharacterCountLabel.text = "\(30 - newLength)"
                    return newLength <= 30
                }
            }
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == convoNameTextField {
            nameCharacterCountLabel.text = "30"
        } else if textField == descriptionTextField {
            descriptionCharacterCountLabel.text = "50"
        }
        return true 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    // MARK: Keyboard Methods
    
    // MUST ADD THIS (Memory leak that will slow application)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // Called everytime the keyboard is shown - Bring up the input area so it isn't hidden (NOT USED)
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        // Retrieve height of the keyboard by accessing its frame
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! CGRect
        let keyboardDuration = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        let keyboardHeight = keyboardFrame.height
        
        // Move the input area up by the height of the keyboard
        createButtonBottomAnchor?.constant = -keyboardHeight - 10
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addImageButton.alpha = 0
            self.partyLabel.alpha = 0
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.title = nil
        }
        
    }
    
    // Dismiss the keyboard and bring back the input area (NOT USED)
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            createButtonBottomAnchor?.constant = -((45/667) * view.bounds.height)
        } else if UIScreen.main.bounds.height == 896 {
            createButtonBottomAnchor?.constant = -((65/667) * view.bounds.height)
        } else {
            createButtonBottomAnchor?.constant = -((25/667) * view.bounds.height)
        }
        
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardDuration = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addImageButton.alpha = 1
            self.partyLabel.alpha = 1
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.handleCancel))
            self.navigationItem.leftBarButtonItem?.tintColor = .purple
            self.navigationItem.title = "Create a Chat"
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
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
    
}
