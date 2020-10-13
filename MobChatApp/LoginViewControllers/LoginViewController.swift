import UIKit
import FirebaseAuth
import FirebaseDatabase
import UIFloatLabelTextField
import FirebaseMessaging

class LoginViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        navigationController?.navigationBar.tintColor = .purple
        navigationController?.isNavigationBarHidden = false
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        navigationController?.navigationBar.transparentNavigationBar()
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        if #available(iOS 11.0, *) {
            emailTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: ((10/667) * view.bounds.height), paddingLeft: (30/375) * view.bounds.width, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        } else {
            emailTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (self.navigationController?.navigationBar.frame.height)! + 20 + 10, paddingLeft: (30/375) * view.bounds.width, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        }
        emailTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 55/667).isActive = true
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 55/667).isActive = true
        
        loginButton.anchor(top: passwordTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, paddingTop: 27, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        loginButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgotPasswordButton.anchor(top: loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 30)
        
        if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            emailTextField.font = UIFont.systemFont(ofSize: 17)
            passwordTextField.font = UIFont.systemFont(ofSize: 17)
        } else if UIScreen.main.bounds.height >= 812 {
            emailTextField.font = UIFont.systemFont(ofSize: 18)
            passwordTextField.font = UIFont.systemFont(ofSize: 18)
        }
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        } else if UIScreen.main.bounds.height == 896 {
            forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        } else if UIScreen.main.bounds.height == 736 {
            forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        } else {
            forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        
    }
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        button.tintColor = .purple
        return button
    }()
    
    @objc func forgotPasswordTapped() {
        let forgotPasswordVC = ForgottenPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    let passwordTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.autocorrectionType = .no
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.isSecureTextEntry = true 
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.tag = 1
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.placeholder = "Email"
        // tf.textContentType = UITextContentType("")
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.tag = 0
        return tf
    }()
    
    let loginButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(loginButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(loginButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(loginButtonTouchDragExit), for: .touchDragExit)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Login", for: .normal)
        button.tintColor = UIColor.white
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.alpha = 0.5
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    @objc func loginButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func loginButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.loginButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func loginButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.loginButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    @objc func loginButtonTapped() {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            self.loginButton.showLoading()
            UIView.animate(withDuration: 0.3, animations: {
                self.loginButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
                    self.presentAlert(alert: "Missing password and/or email")
                    self.loginButton.hideLoading()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.loginButton.transform = CGAffineTransform.identity
                    })
                    return
                }
                
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    
                    if let error = error {
                        self.presentAlert(alert: error.localizedDescription)
                        self.loginButton.hideLoading()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.loginButton.transform = CGAffineTransform.identity
                        })
                        return
                    }
                    
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                        // Reupdate the active notifications section to resubscribe the user for notifications from all his current conversations 
                    Database.database().reference().child("users").child(uid).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let dictionaries = snapshot.value else {return}
                        if dictionaries != nil {
                            Database.database().reference().child("users").child(uid).child("conversations_notifications_active").updateChildValues(dictionaries as! [AnyHashable : Any])
                        }
            
                    })
                    
                    // Get reference to MainTabBarController
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                    
                    // Reset controllers within main tab bar while logging in, so the user is updated in the main tab controller
                    mainTabBarController.setupViewControllers()
                    self.loginButton.hideLoading()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc func handleTextInputChange() {
        // Check if all fields are filled out
        let isFormValid = (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! >= 6
        
        // If the form is valid, the button will change to a dark blue color
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
