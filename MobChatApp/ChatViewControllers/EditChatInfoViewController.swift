import UIKit
import Firebase
import UIFloatLabelTextField

class EditChatInfoViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        convoNameTextField.delegate = self
        descriptionTextField.delegate = self
        introDescriptionTextView.delegate = self 
    }
    
    var originalImage: UIImage?
    var originalDescription: String?
    var originalDisplayDescription: String?
    var originalName: String?
    var conversationId: String?
    
    var editConvoButtonBottomAnchor: NSLayoutConstraint?

    fileprivate func fetchConversationWithConversationId(convoId: String) {
        
        let convoRef = Database.database().reference().child("conversations").child(convoId)
        convoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let conversation = Conversation(dictionary: dictionary)
                guard let conversationImageUrl = conversation.imageUrl else {return}
                self.addImageImageView.loadImage(urlString: conversationImageUrl)
                self.originalImage = self.addImageImageView.image
                
                let conversationDescription = conversation.chatIntroDescription
                self.originalDescription = conversationDescription
                self.introDescriptionTextView.text = conversationDescription
                
                guard let conversationDisplayDescription = conversation.chatDescription else {return}
                self.descriptionTextField.text = conversationDisplayDescription
                self.originalDisplayDescription = conversationDisplayDescription
                self.descriptionCharacterCountLabel.text = "\(50 - conversationDisplayDescription.count)"
                
                guard let conversationName = conversation.conversationName else {return}
                self.convoNameTextField.text = conversationName
                self.originalName = conversationName
                self.nameCharacterCountLabel.text = "\(30 - conversationName.count)"
                
            }
        }, withCancel: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchConversationWithConversationId(convoId: conversationId ?? "")
        
        view.layer.configureGradientBackground(UIColor(red: 0.4314, green: 0.9843, blue: 0.8314, alpha: 1).cgColor,UIColor(red: 0, green: 0.6314, blue: 1, alpha: 1).cgColor)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: (10/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 70, height: 40)
        
        view.addSubview(warningLabel)
        warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        warningLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 15)
        
        view.addSubview(editConvoButton)
        editConvoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editConvoButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (20/667) * view.bounds.height, paddingLeft: (25/375) * view.bounds.width, paddingBottom: 0, paddingRight: (25/375) * view.bounds.width, width: 0, height: 0)
        editConvoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            editConvoButtonBottomAnchor = editConvoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -((20/667) * view.bounds.height))
            editConvoButtonBottomAnchor?.isActive = true
        } else if UIScreen.main.bounds.height == 896 {
            editConvoButtonBottomAnchor = editConvoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -((40/667) * view.bounds.height))
            editConvoButtonBottomAnchor?.isActive = true
        } else if UIScreen.main.bounds.height == 736 {
            editConvoButtonBottomAnchor = editConvoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((45/667) * view.bounds.height))
            editConvoButtonBottomAnchor?.isActive = true
        } else {
            editConvoButtonBottomAnchor = editConvoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -((33/667) * view.bounds.height))
            editConvoButtonBottomAnchor?.isActive = true
        }
        
        view.addSubview(introDescriptionTextView)
        introDescriptionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        introDescriptionTextView.anchor(top: nil, left: editConvoButton.leftAnchor, bottom: editConvoButton.topAnchor, right: editConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (25/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(descriptionCharacterCountLabel)
        descriptionCharacterCountLabel.anchor(top: nil, left: nil, bottom: introDescriptionTextView.topAnchor, right: introDescriptionTextView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (5/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        descriptionCharacterCountLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 20/667).isActive = true
        descriptionCharacterCountLabel.widthAnchor.constraint(equalTo: descriptionCharacterCountLabel.heightAnchor, multiplier: 1).isActive = true
        
        view.addSubview(descriptionTextField)
        descriptionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextField.anchor(top: nil, left: editConvoButton.leftAnchor, bottom: descriptionCharacterCountLabel.topAnchor, right: editConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (3/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(nameCharacterCountLabel)
        nameCharacterCountLabel.anchor(top: nil, left: nil, bottom: descriptionTextField.topAnchor, right: descriptionTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (5/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        nameCharacterCountLabel.heightAnchor.constraint(equalTo: descriptionCharacterCountLabel.heightAnchor).isActive = true
        nameCharacterCountLabel.widthAnchor.constraint(equalTo: nameCharacterCountLabel.heightAnchor, multiplier: 1).isActive = true
        
        // This resizes the description text field, name text field, description text field
        
        if UIScreen.main.bounds.height == 568 { //iphone5, SE
            warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
            convoNameTextField.font = UIFont.systemFont(ofSize: 14)
            descriptionTextField.font = UIFont.systemFont(ofSize: 14)
            introDescriptionTextView.font = UIFont.systemFont(ofSize: 14)
            descriptionCharacterCountLabel.font =  UIFont.systemFont(ofSize: 13)
            nameCharacterCountLabel.font = UIFont.systemFont(ofSize: 13)
            descriptionTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        } else if UIScreen.main.bounds.height == 812 { // For iphoneX
            descriptionTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 105).isActive = true
            warningLabel.font = UIFont.systemFont(ofSize: 11)
             warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -3).isActive = true
        } else if UIScreen.main.bounds.height >= 896 { // iphoneXR,XS
            descriptionTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 105).isActive = true
            warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35).isActive = true
            warningLabel.font = UIFont.systemFont(ofSize: 12)
        } else if UIScreen.main.bounds.height == 736 { // iphone 7,8 pluses
            warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18).isActive = true
            warningLabel.font = UIFont.systemFont(ofSize: 11)
            descriptionTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else { // iphone6,7 
            warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            descriptionTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
            introDescriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        view.addSubview(convoNameTextField)
        convoNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        convoNameTextField.anchor(top: nil, left: editConvoButton.leftAnchor, bottom: nameCharacterCountLabel.topAnchor, right: editConvoButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: (3/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        convoNameTextField.heightAnchor.constraint(equalTo: descriptionTextField.heightAnchor, multiplier: 1).isActive = true
        
        view.addSubview(chatLabel)
        chatLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chatLabel.anchor(top: nil, left: nil, bottom: convoNameTextField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: (15/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        chatLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 200/375).isActive = true
        chatLabel.heightAnchor.constraint(equalTo: chatLabel.widthAnchor, multiplier: 40/200).isActive = true
        
        view.addSubview(addImageImageView)
        addImageImageView.anchor(top: nil, left: nil, bottom: chatLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: (5/667) * view.bounds.height, paddingRight: 0, width: 0, height: 0)
        addImageImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 170/667).isActive = true
        addImageImageView.widthAnchor.constraint(equalTo: addImageImageView.heightAnchor, multiplier: 1).isActive = true
        addImageImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if UIScreen.main.bounds.height >= 736 { // iphone 6+, 6s+, 7+, 8+, iphoneXs
            convoNameTextField.font = UIFont.systemFont(ofSize: 17)
            descriptionTextField.font = UIFont.systemFont(ofSize: 17)
            introDescriptionTextView.font = UIFont.systemFont(ofSize: 17)
        }
        
    }
    
    let chatLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.purple
        label.text = "Chat Picture \n (Tap to Change)"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
        label.textAlignment = .center
        return label
    }()
    
    let warningLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.purple
        label.text = "*Changes will be seen upon app refresh*"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()
    
    lazy var cancelButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.titleLabel?.textColor = UIColor.purple
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.purple
        return button
    }()
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var editConvoButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Save Changes", for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(editConvoButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(editConvoButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(editConvoButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(editConvoButtonTouchDragExit), for: .touchDragExit)
        return button
    }()
    
    @objc func editConvoButtonTouchDown() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.editConvoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func editConvoButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.editConvoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func editConvoButtonTouchDragExit() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.editConvoButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func editConvoButtonTapped() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.editConvoButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            self.editConvoButton.showLoading()
            UIView.animate(withDuration: 0.5, animations: {
                self.editConvoButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                guard let image = self.addImageImageView.image else {
                    self.editConvoButton.hideLoading()
                    return
                }
                guard let uploadData = image.jpegData(compressionQuality: 0.3) else {
                    self.editConvoButton.hideLoading()
                    return
                }
                guard let conversationName = self.convoNameTextField.text, let description = self.descriptionTextField.text, let chatIntroDescription = self.introDescriptionTextView.text, let username = globalUsername, let currentUserUid = Auth.auth().currentUser?.uid else {
                    self.editConvoButton.hideLoading()
                    return
                }
                
                // User didn't change anything
                if self.originalDescription == chatIntroDescription && self.originalImage == image && self.originalName == conversationName && self.originalDisplayDescription == description {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.editConvoButton.transform = CGAffineTransform.identity
                    }, completion: nil)
                    self.editConvoButton.hideLoading()
                    self.presentAlert(alert: "You didn't change anything")
                    return
                }
                
                if !conversationName.trimmingCharacters(in: .whitespaces).isEmpty && !chatIntroDescription.trimmingCharacters(in: .whitespaces).isEmpty && !description.trimmingCharacters(in: .whitespaces).isEmpty {
                    
                    guard let conversationId = self.conversationId else {return}
                    
                    let storageRef = Storage.storage().reference().child("convo_images").child(conversationId)

                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            
                        if let error = error {
                            print ("Failed to upload new convo image to storage:", error)
                            UIView.animate(withDuration: 0.5, animations: {
                                self.editConvoButton.transform = CGAffineTransform.identity
                            }, completion: nil)
                            self.editConvoButton.hideLoading()
                            return
                        }
                        
                        storageRef.downloadURL(completion: { (url, error) in
                            
                            if error != nil {
                                print ("Couldn't convert to download url")
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.editConvoButton.transform = CGAffineTransform.identity
                                }, completion: nil)
                                self.editConvoButton.hideLoading()
                                return
                            }
                        
                            guard let convoImageUrl = url?.absoluteString else {return}
                            
                            let ref = Database.database().reference()
                            guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
                            let log = [currentUserUid: self.checkForEdits(name: conversationName, image: image, shortDescription: description, longDescription: chatIntroDescription, username: username)]
                            
                            let values = ["/conversations/\(conversationId)/conversationName/":conversationName, "/conversations/\(conversationId)/conversationImageUrl/":convoImageUrl, "/conversations/\(conversationId)/description/":description, "/conversations/\(conversationId)/chatIntroDescription/":chatIntroDescription, "/highlights_log/\(conversationId)/\(logKey)":log] as [String:AnyObject]
                            ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
                                if let error = error {
                                    print ("Failed to update conversation data:", error)
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.editConvoButton.transform = CGAffineTransform.identity
                                    }, completion: nil)
                                    self.editConvoButton.hideLoading()
                                    return
                                }
                                    
                                self.editConvoButton.hideLoading()
                                self.dismiss(animated: true, completion: nil)
                            })
                                
                                
                        })
                            
                    }
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.editConvoButton.transform = CGAffineTransform.identity
                    }, completion: { (_) in
                        self.editConvoButton.hideLoading()
                        self.presentAlert(alert: "All fields must be filled in")
                    })
                }
            })
        }
    }
    
    fileprivate func checkForEdits(name: String, image: UIImage, shortDescription: String, longDescription: String, username: String) -> String {
        
        var string = "\(username) has changed the chat"
        var marker = 0
        
        if self.originalDescription != longDescription && self.originalImage != image && self.originalName != name && self.originalDisplayDescription != shortDescription {
            return "\(username) has changed the chat name, description, display description and image"
        }
        
        if self.originalDescription != longDescription {
            string += " long description"
            marker += 1
        }
        if self.originalImage != image {
            if marker > 0 {
                string += " and image"
            } else {
                string += " image"
            }
            marker += 1
        }
        if self.originalName != name {
            if marker > 0 {
                string += " and name"
            } else {
                string += " name"
            }
            marker += 1
        }
        if self.originalDisplayDescription != shortDescription {
            if marker > 0 {
                string += " and display description"
            } else {
                string += " display description"
            }
        }
        string += "\u{1F4CB}"
        
        return string
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addImageImageView.layer.cornerRadius = addImageImageView.bounds.height / 2
    }
    
    lazy var addImageImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.tintColor = UIColor(red: 0.4706, green: 0.0000, blue: 0.8902, alpha: 1)
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.purple.cgColor
        iv.layer.borderWidth = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))
        return iv
    }()
    
    @objc func imageViewTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addImageImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            addImageImageView.image = editedImage.withRenderingMode(.alwaysOriginal)
        }
        
        addImageImageView.layer.cornerRadius = addImageImageView.frame.width / 2
        addImageImageView.layer.masksToBounds = true
        addImageImageView.layer.borderColor = UIColor.purple.cgColor
        addImageImageView.layer.borderWidth = 1
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    lazy var convoNameTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.tag = 0
        tf.tintColor = .black
        tf.placeholder = "Chat Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03) 
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
        tf.placeholder = "Display Description"
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
    
    lazy var introDescriptionTextView: DescriptionTextView2 = {
        let tv = DescriptionTextView2()
        tv.contentInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        tv.tintColor = .black
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.isScrollEnabled = true
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.font = UIFont.systemFont(ofSize: 15)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
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

    
    // MUST ADD THIS (Memory leak that will slow application)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
    
    // Called everytime the keyboard is shown - Bring up the input area so it isn't hidden (NOT USED)
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        // Retrieve height of the keyboard by accessing its frame
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! CGRect
        let keyboardDuration = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        let keyboardHeight = keyboardFrame.height
        
        // Move the input area up by the height of the keyboard
        editConvoButtonBottomAnchor?.constant = -keyboardHeight - 5
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addImageImageView.alpha = 0
            self.chatLabel.alpha = 0
            self.cancelButton.alpha = 0
        }
        
    }
    
    // Dismiss the keyboard and bring back the input area (NOT USED)
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            editConvoButtonBottomAnchor?.constant = -((20/667) * view.bounds.height)
        } else if UIScreen.main.bounds.height == 896 {
            editConvoButtonBottomAnchor?.constant = -((40/667) * view.bounds.height)
        } else {
            editConvoButtonBottomAnchor?.constant = -((33/667) * view.bounds.height)
        }
        
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardDuration = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addImageImageView.alpha = 1
            self.chatLabel.alpha = 1
            self.cancelButton.alpha = 1
        }
        
    }
    
}
