import UIKit
import FirebaseAuth

class AuthenticationViewController: UIViewController, UITextFieldDelegate {
    
    var updateEmail: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        passwordTextField.becomeFirstResponder()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addSubview(emailTextField)
        view.addSubview(emailLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordLabel)
        // MARK: Safearea layout guide

        if #available(iOS 11.0, *) {
            emailLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        } else {
            emailLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: (self.navigationController?.navigationBar.frame.height)! + 20 + ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        }
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 80/375).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 35/667).isActive = true
        
        emailTextField.anchor(top: nil, left: emailLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 250/375).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: emailTextField.widthAnchor, multiplier: 35/260).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor).isActive = true
        
        passwordLabel.anchor(top: emailTextField.bottomAnchor, left: emailLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordLabel.widthAnchor.constraint(equalTo: emailLabel.widthAnchor).isActive = true
        passwordLabel.heightAnchor.constraint(equalTo: emailLabel.heightAnchor).isActive = true
        
        passwordTextField.anchor(top: nil, left: passwordLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 3, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordTextField.centerYAnchor.constraint(equalTo: passwordLabel.centerYAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor, multiplier: 1).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor, multiplier: 1).isActive = true

        navigationItem.title = "Authentication" 
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPressed))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(continuePressed))
        navigationItem.rightBarButtonItem?.tintColor = .black

    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(style: .white)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    // Prevent the pushing of a VC multiple times with rapid button taps
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func continuePressed() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let currentUser = Auth.auth().currentUser
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (result, error) in
            
            if error != nil {
                print (error as Any)
                self.presentAlert(alert: "Wrong email and/or password")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                self.navigationItem.rightBarButtonItem?.customView = nil
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(self.continuePressed))
                self.navigationItem.rightBarButtonItem?.tintColor = .black
                return
            }
            
            self.activityIndicatorView.stopAnimating()
            self.navigationItem.rightBarButtonItem?.customView = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(self.continuePressed))
            self.navigationItem.rightBarButtonItem?.tintColor = .black
            
            if self.updateEmail == true {
                // Send to email VC
                let updateEmailVC = UpdateEmailController()
                self.navigationController?.pushViewController(updateEmailVC, animated: true)
            } else if self.updateEmail == false {
                let updatePasswordVC = UpdatePasswordViewController()
                self.navigationController?.pushViewController(updatePasswordVC, animated: true)
            }
            
        })
    }
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 0
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.tintColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 1
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
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
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true 
    }
    
}
