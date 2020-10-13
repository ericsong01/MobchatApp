import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditUserProfileController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var email: String?
    
    var userProfileVC: UserProfileController?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = globalEmail
        bioTextView.text = globalBiography
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        emailTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black 
        navigationItem.title = "Edit Profile"
        
        setupTextFieldsAndLabels()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
    }
    
    fileprivate func setupTextFieldsAndLabels() {
        view.addSubview(profileImageView)
        view.addSubview(changeProfilePicButton)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(passwordLabel)
        view.addSubview(personalInfoLabel)
        view.addSubview(bioLabel)
        view.addSubview(bioTextView)
        view.addSubview(textViewButton)
        view.addSubview(emailTextFieldButton)
        view.addSubview(passwordTextFieldButton)
        
        if #available(iOS 11.0, *) {
            profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        } else {
            profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: (self.navigationController?.navigationBar.frame.height)! + 20 + (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 150/375).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1).isActive = true
        
        changeProfilePicButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        changeProfilePicButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        changeProfilePicButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 200/375).isActive = true
        changeProfilePicButton.heightAnchor.constraint(equalTo: changeProfilePicButton.widthAnchor, multiplier: 33/200).isActive = true
        
        nameLabel.anchor(top: changeProfilePicButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height, paddingLeft: (15/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 80/375).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: nameLabel.widthAnchor, multiplier: 35/80).isActive = true
        
        nameTextField.anchor(top: nil, left: nameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 260/375).isActive = true
        nameTextField.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        
        bioLabel.anchor(top: nameTextField.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bioLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor).isActive = true
        bioLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor).isActive = true
        
        bioTextView.anchor(top: nameTextField.bottomAnchor, left: bioLabel.rightAnchor, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bioTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 260/375).isActive = true
        
        textViewButton.anchor(top: bioTextView.topAnchor, left: bioTextView.leftAnchor, bottom: bioTextView.bottomAnchor, right: bioTextView.rightAnchor, paddingTop: 0.5, paddingLeft: 0.5, paddingBottom: 0.5, paddingRight: 0.5, width: 0, height: 0)
        
        if UIScreen.main.bounds.size.width <= 320 {
            bioTextView.font = UIFont.systemFont(ofSize: 13.0)
        } else if UIScreen.main.bounds.size.width > 320 {
            bioTextView.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        personalInfoLabel.anchor(top: bioTextView.bottomAnchor, left: bioLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (20/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        personalInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 150/375).isActive = true
        personalInfoLabel.heightAnchor.constraint(equalTo: personalInfoLabel.widthAnchor, multiplier: 35/150).isActive = true
        
        emailLabel.anchor(top: personalInfoLabel.bottomAnchor, left: personalInfoLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 80/375).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: emailLabel.widthAnchor, multiplier: 35/80).isActive = true
        
        emailTextField.anchor(top: nil, left: emailLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emailTextField.widthAnchor.constraint(equalTo: nameTextField.widthAnchor, multiplier: 1).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor, multiplier: 1).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor).isActive = true
        
        emailTextFieldButton.anchor(top: emailTextField.topAnchor, left: emailTextField.leftAnchor, bottom: emailTextField.bottomAnchor, right: emailTextField.rightAnchor, paddingTop: 0.5, paddingLeft: 0.5, paddingBottom: 0.5, paddingRight: 0.5, width: 0, height: 0)
        
        passwordLabel.anchor(top: emailTextField.bottomAnchor, left: emailLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordLabel.widthAnchor.constraint(equalTo: emailLabel.widthAnchor, multiplier: 1).isActive = true
        passwordLabel.heightAnchor.constraint(equalTo: emailLabel.heightAnchor, multiplier: 1).isActive = true
        
        passwordTextField.anchor(top: nil, left: passwordLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor, multiplier: 1).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor, multiplier: 1).isActive = true
        passwordTextField.centerYAnchor.constraint(equalTo: passwordLabel.centerYAnchor).isActive = true
        
        passwordTextFieldButton.anchor(top: passwordTextField.topAnchor, left: passwordTextField.leftAnchor, bottom: passwordTextField.bottomAnchor, right: passwordTextField.rightAnchor, paddingTop: 0.5, paddingLeft: 0.5, paddingBottom: 0.5, paddingRight: 0.5, width: 0, height: 0)
        
        nameTextField.text = userProfileVC?.nameLabel.text
        guard let profileImageUrl = globalProfileImageUrl else {return}
        profileImageView.loadImage(urlString: profileImageUrl)
        bioTextView.sizeToFit()
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(style: .white)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        return aiv
        
    }()

    @objc func doneTapped() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference().child("profile_images").child(uid)
        
        guard let image = self.profileImageView.image else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
        
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print ("Couldn't upload new profile pic:", error as Any)
                    self.activityIndicatorView.stopAnimating()
                    self.navigationItem.rightBarButtonItem?.customView = nil
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
                    self.navigationItem.rightBarButtonItem?.tintColor = .black
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print ("Couldn't retrieve download url:", error as Any)
                        self.activityIndicatorView.stopAnimating()
                        self.navigationItem.rightBarButtonItem?.customView = nil
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
                        self.navigationItem.rightBarButtonItem?.tintColor = .black
                        return
                    }
                    
                    guard let profileImageUrl = url?.absoluteString else {return}
                    guard let username = self.nameTextField.text else {return}
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl]
                    
                    Database.database().reference().child("users").child(uid).updateChildValues(dictionaryValues, withCompletionBlock: { (error, ref) in
                        
                        if error != nil {
                            print ("Couldn't update user data:", error as Any)
                            self.activityIndicatorView.stopAnimating()
                            self.navigationItem.rightBarButtonItem?.customView = nil
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
                            self.navigationItem.rightBarButtonItem?.tintColor = .black
                            return
                        }
                        
                        globalUsername = self.nameTextField.text
                        globalProfileImageUrl = profileImageUrl
                        self.userProfileVC?.profileImageView.loadImage(urlString: profileImageUrl)
                        self.activityIndicatorView.stopAnimating()
                        self.navigationItem.rightBarButtonItem?.customView = nil
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
                        self.navigationItem.rightBarButtonItem?.tintColor = .black
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                    })
                    
                })
                
            }
        }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 75
        return iv
    }()
    
    let changeProfilePicButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 5.0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(changeProfilePicSelected), for: .touchUpInside)
        button.setTitle("Change Profile Picture", for: .normal)
        return button
    }()
    
    @objc func changeProfilePicSelected() {
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
            profileImageView.image = originalImage
            profileImageView.contentMode = .scaleAspectFill
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            profileImageView.contentMode = .scaleAspectFill
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    let personalInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Personal Info"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.text = "password"
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        return tf
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let passwordTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(passwordTextFieldButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(passwordTextFieldHeldDown), for: .touchDown)
        button.addTarget(self, action: #selector(passwordTextFieldHeldAndReleased), for: .touchDragExit)
        return button
    }()
    
    @objc func passwordTextFieldButtonTapped() {
        passwordTextFieldButton.backgroundColor = .clear
        let authVC = AuthenticationViewController()
        authVC.updateEmail = false
        authVC.emailTextField.text = globalEmail
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    @objc func passwordTextFieldHeldDown() {
        passwordTextFieldButton.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    @objc func passwordTextFieldHeldAndReleased() {
        passwordTextFieldButton.backgroundColor = .clear
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        return tf
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        return tf
    }()
    
    let emailTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(emailTextFieldButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(emailTextFieldButtonHeldDown), for: .touchDown)
        button.addTarget(self, action: #selector(emailTextFieldButtonHeldAndReleased), for: .touchDragExit)
        return button
    }()
    
    @objc func emailTextFieldButtonTapped() {
        emailTextFieldButton.backgroundColor = .clear
        let authVC = AuthenticationViewController()
        authVC.updateEmail = true
        authVC.emailTextField.text = globalEmail
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    @objc func emailTextFieldButtonHeldDown() {
        emailTextFieldButton.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    @objc func emailTextFieldButtonHeldAndReleased() {
        emailTextFieldButton.backgroundColor = .clear
    }
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 5
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    let textViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(textViewButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(textViewButtonHeldDown), for: .touchDown)
        button.addTarget(self, action: #selector(textViewButtonHeldAndReleased), for: .touchDragExit)
        return button
    }()
    
    @objc func textViewButtonTapped() {
        print ("button tapped")
        textViewButton.backgroundColor = .clear
        let bioVC = BioTextViewController()
        bioVC.bio = globalBiography
        navigationController?.pushViewController(bioVC, animated: true)
    }
    
    @objc func textViewButtonHeldDown() {
        textViewButton.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    @objc func textViewButtonHeldAndReleased(){
        textViewButton.backgroundColor = .clear
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
        if textField == nameTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 20 // Bool
        }
        return false
    }
    
    // TextField Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}
