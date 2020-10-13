import UIKit
import UIFloatLabelTextField
import FirebaseAuth

class ForgottenPasswordViewController: UIViewController, UITextFieldDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        
         view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        
        view.addSubview(emailTextField)

        if #available(iOS 11.0, *) {
            emailTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: ((10/667) * view.bounds.height), paddingLeft: (30/375) * view.bounds.width, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        } else {
            emailTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((10/667) * view.bounds.height), paddingLeft: (30/375) * view.bounds.width, paddingBottom: 0, paddingRight: (30/375) * view.bounds.width, width: 0, height: 0)
        }
        emailTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 55/667).isActive = true
        
        view.addSubview(submitButton)
        submitButton.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, paddingTop: (27/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        submitButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
        
        if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            emailTextField.font = UIFont.systemFont(ofSize: 17)
        } else if UIScreen.main.bounds.height >= 812 {
            emailTextField.font = UIFont.systemFont(ofSize: 18)
        }
    }
    
    let emailTextField: UIFloatLabelTextField = {
        let tf = UIFloatLabelTextField()
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    
    let submitButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
        button.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(resetPasswordButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(resetPasswordButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(resetPasswordButtonTouchDragExit), for: .touchDragExit)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Reset Password", for: .normal)
        button.tintColor = UIColor.white
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.alpha = 0.5
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    @objc func resetPasswordButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.submitButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    @objc func resetPasswordButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.submitButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func resetPasswordButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.submitButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    @objc func resetPasswordButtonTapped() {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.submitButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.submitButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                guard let email = self.emailTextField.text else {return}
                self.submitButton.showLoading()
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        self.presentAlert(alert: error.localizedDescription)
                        self.submitButton.transform = CGAffineTransform.identity
                        self.submitButton.hideLoading()
                        return
                    }
                    self.presentSuccessAlert(alert: "Password reset instructions have been sent to \(email)")
                    self.submitButton.hideLoading()
                }
            })
        }
    }
    
    @objc func handleTextInputChange() {
        // Check if all fields are filled out
        let isFormValid = (emailTextField.text?.count)! > 0
        
        // If the form is valid, the button will change to a dark blue color
        if isFormValid {
            submitButton.isEnabled = true
            submitButton.alpha = 1
        } else {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        }
    }
    
    // TextField Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true 
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
    
    // Success Alert function
    func presentSuccessAlert(alert:String) {
        
        let alertVC = UIAlertController(title: "Success", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
}
