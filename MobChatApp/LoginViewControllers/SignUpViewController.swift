import UIKit
import Firebase
import FirebaseMessaging
import UIFloatLabelTextField

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private var datePicker: UIDatePicker?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageViewButton.layer.cornerRadius = profileImageViewButton.bounds.height / 2 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .purple
        
        navigationController?.isNavigationBarHidden = false
                
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        
        navigationController?.navigationBar.transparentNavigationBar()

        view.addSubview(signUpButton)
        view.addSubview(profileImageLabel)
        view.addSubview(profileImageLabel)
        view.addSubview(profileImageViewButton)

        signUpButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 27, paddingBottom: 0, paddingRight: 27, width: 0, height: 0)
        signUpButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.074962).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(termsAndConditionsButton)
        termsAndConditionsButton.anchor(top: signUpButton.bottomAnchor, left: signUpButton.leftAnchor, bottom: nil, right: signUpButton.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
        
        if UIScreen.main.bounds.height == 568 {
            signUpButtonBottomAnchor = signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(70/667)*view.bounds.height)
            signUpButtonBottomAnchor?.isActive = true
        } else {
            signUpButtonBottomAnchor = signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(100/667)*view.bounds.height)
            signUpButtonBottomAnchor?.isActive = true
        }
        
        view.addSubview(dateTextField)
        dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateTextField.anchor(top: nil, left: signUpButton.leftAnchor, bottom: signUpButton.topAnchor, right: signUpButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        dateTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08245877).isActive = true
        
        view.addSubview(passwordTextField)
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.anchor(top: nil, left: signUpButton.leftAnchor, bottom: dateTextField.topAnchor, right: signUpButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        passwordTextField.heightAnchor.constraint(equalTo: dateTextField.heightAnchor).isActive = true
        
        view.addSubview(emailTextField)
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.anchor(top: nil, left: signUpButton.leftAnchor, bottom: passwordTextField.topAnchor, right: signUpButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        emailTextField.heightAnchor.constraint(equalTo: dateTextField.heightAnchor).isActive = true
        
        view.addSubview(nameTextField)
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.anchor(top: nil, left: view.leftAnchor, bottom: emailTextField.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 27, paddingBottom: 8, paddingRight: 27, width: 0, height: 0)
        nameTextField.heightAnchor.constraint(equalTo: dateTextField.heightAnchor).isActive = true
        
        profileImageLabel.anchor(top: nil, left: nil, bottom: nameTextField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        profileImageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.346666).isActive = true
        profileImageLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 27/667).isActive = true
        
        profileImageViewButton.anchor(top: nil, left: nil, bottom: profileImageLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        profileImageViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageViewButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 145/667).isActive = true
        profileImageViewButton.widthAnchor.constraint(equalTo: profileImageViewButton.heightAnchor).isActive = true
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        dateTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            nameTextField.font = UIFont.systemFont(ofSize: 17)
            emailTextField.font = UIFont.systemFont(ofSize: 17)
            passwordTextField.font = UIFont.systemFont(ofSize: 17)
            dateTextField.font = UIFont.systemFont(ofSize: 17)
            profileImageLabel.font = UIFont(name: "Rockwell", size: 15)
            termsAndConditionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        } else if UIScreen.main.bounds.height >= 812 {
            nameTextField.font = UIFont.systemFont(ofSize: 18)
            emailTextField.font = UIFont.systemFont(ofSize: 18)
            passwordTextField.font = UIFont.systemFont(ofSize: 18)
            dateTextField.font = UIFont.systemFont(ofSize: 18)
            profileImageLabel.font = UIFont(name: "Rockwell", size: 16)
            termsAndConditionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    var signUpButtonBottomAnchor: NSLayoutConstraint?
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        
        checkAllFieldsFilled()
    }
    
    let dateTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.placeholder = "Birthday"
        tf.tag = 3
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .valueChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        checkAllFieldsFilled()
    }
    
    fileprivate func checkAllFieldsFilled() {
        // Check if all fields are filled out
        let isFormValid = (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! >= 6 && (nameTextField.text?.count)! > 0 && (dateTextField.text?.count)! > 0
        
        // If the form is valid, the button will change to a dark blue color
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.alpha = 1
        } else {
            signUpButton.isEnabled = false
            signUpButton.alpha = 0.5
        }
    }
    
    let profileImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Picture"
        label.font = UIFont(name: "Rockwell", size: 14)
        label.textAlignment = .center
        label.textColor = .purple
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let signUpButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
        button.addTarget(self, action: #selector(signUpUserTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(signUpButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(signUpButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(signUpButtonTouchDragExit), for: .touchDragExit)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = UIColor.white
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true 
        button.alpha = 0.5
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    @objc func signUpButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func signUpButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.signUpButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func signUpButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.signUpButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func signUpUserTapped() {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            self.signUpButton.showLoading()
            UIView.animate(withDuration: 0.3, animations: {
                self.signUpButton.transform = CGAffineTransform.identity
            })
            
            guard let email = self.emailTextField.text, email.count > 0, let username = self.nameTextField.text, username.count > 0, let password = self.passwordTextField.text, password.count > 0 else {
                self.presentAlert(alert: "All fields including a profile picture must be completed")
                self.signUpButton.hideLoading()
                UIView.animate(withDuration: 0.3, animations: {
                    self.signUpButton.transform = CGAffineTransform.identity
                })
                return
            }
            
            guard let birthday = self.datePicker?.date else {return}
            let now = Date()
            var ageComponents = Calendar.current.dateComponents([.year], from: birthday, to: now)
            let age: Int = ageComponents.year!
            print (age)
            if age < 13 {
                self.presentAlert(alert: "This app may contain mature content. Therefore, you must be at least 13 years to be able to use this app :(")
                UIView.animate(withDuration: 0.3, animations: {
                    self.signUpButton.transform = CGAffineTransform.identity
                })
                self.signUpButton.hideLoading()
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if let error = error {
                    self.presentAlert(alert: error.localizedDescription)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.signUpButton.transform = CGAffineTransform.identity
                    })
                    self.signUpButton.hideLoading()
                    return
                }
                
                guard let image = self.profileImageViewButton.imageView?.image else {return}
                guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
                
                guard let uid = user?.user.uid else {return}
                let storageRef = Storage.storage().reference().child("profile_images").child(uid)
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if let error = error {
                        print ("Failed to upload profile image to storage:", error)
                        UIView.animate(withDuration: 0.5, animations: {
                            self.signUpButton.transform = CGAffineTransform.identity
                        })
                        self.signUpButton.hideLoading()
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        
                        if let error = error {
                            print ("Couldn't retrieve download url:", error)
                            UIView.animate(withDuration: 0.3, animations: {
                                self.signUpButton.transform = CGAffineTransform.identity
                            })
                            self.signUpButton.hideLoading()
                            return
                        }
                        
                        guard let profileImageUrl = url?.absoluteString else {return}
                        guard let fcmToken = Messaging.messaging().fcmToken else {return}
                        
                        let userConvoValues = ["/conversation_users/-LRSCwfLZigGmPwTvogE/\(uid)":1, "/users/\(uid)/conversations_notifications_active/-LRSCwfLZigGmPwTvogE/":1, "/users/\(uid)/username": username, "/users/\(uid)/profileImageUrl": profileImageUrl, "/users/\(uid)/fcmToken": fcmToken, "/users/\(uid)/conversations/-LRSCwfLZigGmPwTvogE/": 1] as [String : Any]
                        
                        Database.database().reference().updateChildValues(userConvoValues, withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print ("Failed to save user info into DB", error as Any)
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.signUpButton.transform = CGAffineTransform.identity
                                })
                                self.signUpButton.hideLoading()
                                return
                            }
                                // Get reference to MainTabBarController
                                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                                
                                // Reset controllers within main tab bar while logging in, so the user is updated in the main tab controller
                                mainTabBarController.setupViewControllers()
                                self.signUpButton.hideLoading()
                                self.dismiss(animated: true, completion: nil)
                            
                        })
                    })
                    
                })
                
            }
        }
    }
    
    let nameTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.placeholder = "Username"
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.tag = 0
        return tf
    }()
    
    let emailTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.tag = 1
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.tag = 2
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let profileImageViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "anon_user_picture")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor.purple
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.purple.cgColor
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleProfileImageViewTapped), for: .touchUpInside)
        return button
    }()
    
    let termsAndConditionsButton: UIButton = {
       let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "By signing up you agree to the ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        attributedTitle.append(NSAttributedString(string: "Terms and Conditions", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor(r: 17, g: 154, b: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(bringUpTermsAndConditionsVC), for: .touchUpInside)
        return button
    }()
    
    @objc func bringUpTermsAndConditionsVC() {
        let termsVC = TermsAndConditionsViewController()
        let navController = UINavigationController(rootViewController: termsVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleProfileImageViewTapped() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // Create reference to alert to popup to choose photo library or camera
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera option alert
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }))
        
        // Photo Library option alert
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }))
        
        // Add cancel option and present option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageViewButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImageViewButton.imageView?.contentMode = .scaleAspectFill
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageViewButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImageViewButton.imageView?.contentMode = .scaleAspectFill
        }
        
        profileImageViewButton.layer.cornerRadius = profileImageViewButton.frame.width / 2
        profileImageViewButton.layer.masksToBounds = true
        profileImageViewButton.layer.borderColor = UIColor.purple.cgColor
        profileImageViewButton.layer.borderWidth = 1.5
        
        dismiss(animated: true, completion: nil)
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
    
    // TextField Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 20 // Bool
        }
        return true
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
        signUpButtonBottomAnchor?.constant = -keyboardHeight - 10
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.profileImageLabel.alpha = 0
            self.profileImageViewButton.alpha = 0
        }
        
    }
    
    // Dismiss the keyboard and bring back the input area (NOT USED)
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        
        if UIScreen.main.bounds.height == 568 {
            signUpButtonBottomAnchor?.constant = -(70/667) * view.bounds.height
        } else {
            signUpButtonBottomAnchor?.constant = -(100/667) * view.bounds.height
        }
        
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardDuration = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        
        // Animate the keyboard slide up
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.profileImageLabel.alpha = 1
            self.profileImageViewButton.alpha = 1
        }
        
    }
    
}
