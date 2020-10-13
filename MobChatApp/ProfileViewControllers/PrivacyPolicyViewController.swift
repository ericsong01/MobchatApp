import SafariServices
import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: (10/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        dismissButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 90/375).isActive = true
        dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 40/90).isActive = true
        
        view.addSubview(privacyPolicyLabel)
        privacyPolicyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/375).isActive = true
        privacyPolicyLabel.heightAnchor.constraint(equalTo: privacyPolicyLabel.widthAnchor, multiplier: 275/300).isActive = true
        privacyPolicyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        privacyPolicyLabel.anchor(top: dismissButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (60/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(linkButton)
        linkButton.anchor(top: privacyPolicyLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (30/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 40)
        linkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(creditsButton)
        creditsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        creditsButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 125/375).isActive = true
        creditsButton.heightAnchor.constraint(equalTo: creditsButton.widthAnchor, multiplier: 40/60).isActive = true
        creditsButton.anchor(top: linkButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (25/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.text = "Email me at esong2288@gmail.com with your email and username if you wish to withdraw consent for using data collected for advertising, analytics, crash logging. This means your account will be terminated, along with images stored."
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let linkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Privacy Policy", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func linkButtonTapped() {
        let url = NSURL(string: "https://sites.google.com/view/mobchatprivacypolicy#h.p_RSMJK8vxTrcP")! as URL
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    let creditsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Credits/Contact", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(creditsTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func creditsTapped() {
        let creditsVC = CreditsViewController()
        self.present(creditsVC, animated: true, completion: nil)
    }
}
