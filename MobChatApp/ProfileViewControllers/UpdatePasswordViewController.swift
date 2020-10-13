import UIKit
import FirebaseAuth
import FirebaseDatabase

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        passwordTextField2.delegate = self
        
        passwordTextField.becomeFirstResponder()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Update Password"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPressed))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordTextField2)

        // MARK: Safearea layout guide

        if #available(iOS 11.0, *) {
            passwordLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 150, height: 35)
        } else {
            passwordLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: (self.navigationController?.navigationBar.frame.height)! + 20 + ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 150, height: 35)
        }

        passwordTextField.anchor(top: passwordLabel.bottomAnchor, left: passwordLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 315/375).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: passwordTextField.widthAnchor, multiplier: 35/315).isActive = true
        
        passwordTextField2.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        passwordTextField2.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor, multiplier: 1).isActive = true
        passwordTextField2.heightAnchor.constraint(equalTo: passwordTextField.heightAnchor, multiplier: 1).isActive = true
    }
    
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneTapped() {
        let currentUser = Auth.auth().currentUser
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        guard passwordTextField.text == passwordTextField2.text else {
            presentAlert(alert: "Passwords don't match")
            self.activityIndicatorView.stopAnimating()
            self.navigationItem.rightBarButtonItem?.customView = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
            self.navigationItem.rightBarButtonItem?.tintColor = .black
            return
        }
        
        guard let password = passwordTextField.text else {return}
        
        currentUser?.updatePassword(to: password, completion: { (error) in
            
            if error != nil {
                self.presentAlert(alert: "Password must be longer than 5 characters")
                self.activityIndicatorView.stopAnimating()
                self.navigationItem.rightBarButtonItem?.customView = nil
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
                self.navigationItem.rightBarButtonItem?.tintColor = .black
                return
            }
            self.activityIndicatorView.stopAnimating()
            self.navigationItem.rightBarButtonItem?.customView = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneTapped))
            self.navigationItem.rightBarButtonItem?.tintColor = .black
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(style: .white)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 0
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        tf.tintColor = .black
        tf.placeholder = "New Password"
        return tf
    }()
    
    let passwordTextField2: UITextField = {
        let tf = UITextField()
        tf.tag = 1
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Confirm password"
        return tf
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "New Password"
        label.font = UIFont(name: "Rockwell", size: 17)
        label.font = UIFont.boldSystemFont(ofSize: 17)
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
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
