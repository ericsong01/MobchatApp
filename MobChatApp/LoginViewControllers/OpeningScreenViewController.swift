import UIKit

class OpeningScreenViewController: UIViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signUpButton.layer.cornerRadius = signUpButton.bounds.height / 2
    }
    
    var font: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)

        view.addSubview(partyChatLabel)
        partyChatLabel.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0.2548 * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        partyChatLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/375).isActive = true
        partyChatLabel.heightAnchor.constraint(equalTo: partyChatLabel.widthAnchor, multiplier: 60/300).isActive = true
        partyChatLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(partyChatDescription)
        partyChatDescription.anchor(top: partyChatLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        partyChatDescription.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 350/375).isActive = true
        partyChatDescription.heightAnchor.constraint(equalTo: partyChatDescription.widthAnchor, multiplier: 23/375).isActive = true
        partyChatDescription.centerXAnchor.constraint(equalTo: partyChatLabel.centerXAnchor).isActive = true
        
        animateImageView()
        
        view.addSubview(loginButton)
        view.addSubview(signUpButton)

        signUpButton.anchor(top: animatedImageView.topAnchor, left: animatedImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 50, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.32).isActive = true
        signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 0.4166).isActive = true
        
        loginButton.anchor(top: signUpButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 7, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 175/375).isActive = true
        loginButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 30/667).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor).isActive = true
        
        if UIScreen.main.bounds.height == 812 { // For iphoneXs
            loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        } else if UIScreen.main.bounds.height == 896 {
            loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        } else if UIScreen.main.bounds.height == 736 {
            loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        } else {
            loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        
    }
    
    fileprivate func animateImageView() {
        view.addSubview(animatedImageView)
        animatedImageView.anchor(top: partyChatDescription.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 37, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        animatedImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.26666).isActive = true
        animatedImageView.heightAnchor.constraint(equalTo: animatedImageView.widthAnchor, multiplier: 2.2).isActive = true
        
        var imagesNames = ["win_1", "win_2", "win_3", "win_4", "win_5", "win_6", "win_7", "win_8", "win_9", "win_10", "win_11", "win_12", "win_13", "win_14", "win_15", "win_16"]
        
        var images = [UIImage]()
        
        for i in 0..<imagesNames.count {
            images.append(UIImage(named: imagesNames[i])!)
        }
        
        animatedImageView.animationImages = images
        animatedImageView.animationDuration = 1.5
        animatedImageView.startAnimating()
    }
    
    let animatedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let partyChatLabel: UILabel = {
       let label = UILabel()
        label.text = "MobChat"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Rockwell", size: 50)
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()
    
    let partyChatDescription: UILabel = {
        let label = UILabel()
        label.text = "Open Group Chat"
        label.font = UIFont(name: "Rockwell", size: 14)
        label.textAlignment = .center
        return label
    }()
    
    let signUpButton: LoadingButton = {
        let button = LoadingButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = UIColor.white
        button.setBackgroundImage(#imageLiteral(resourceName: "purple_gradient"), for: .normal)
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(signUpButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(signUpButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(signUpButtonTouchDragExit), for: .touchDragExit)
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
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
    
    @objc func signUpTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.signUpButton.transform = CGAffineTransform.identity // Reset to default size
            }, completion: { (_) in
                let signUpVC = SignUpViewController()
                self.navigationController?.pushViewController(signUpVC, animated: true)
            })
        }
    }

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I already have an account", for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.tintColor = .black
        return button
    }()
    
    @objc func loginTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
