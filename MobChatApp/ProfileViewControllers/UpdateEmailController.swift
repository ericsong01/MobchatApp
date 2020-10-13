import UIKit
import FirebaseAuth 

class UpdateEmailController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self 
        emailTextField.becomeFirstResponder()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Update Email"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPressed))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)

        if #available(iOS 11.0, *) {
            emailLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 150, height: 35)
        } else {
            emailLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: (self.navigationController?.navigationBar.frame.height)! + 20 + ((20/667) * view.bounds.height), paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 150, height: 35)
        }
        
        emailTextField.anchor(top: emailLabel.bottomAnchor, left: emailLabel.leftAnchor, bottom: nil, right: nil, paddingTop: (15/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 315/375).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: emailTextField.widthAnchor, multiplier: 35/315).isActive = true
    }
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "New Email"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "New Email"
        tf.borderStyle = .roundedRect
        tf.tintColor = .black
        return tf
    }()
    
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(style: .white)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = UIColor.black
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    @objc func doneTapped() {
        let currentUser = Auth.auth().currentUser
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()

        guard let email = emailTextField.text else {return}
        
        currentUser?.updateEmail(to: email, completion: { (error) in
            
            if error != nil {
                self.presentAlert(alert: "Please input an email")
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
            globalEmail = email
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })

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
    
}
