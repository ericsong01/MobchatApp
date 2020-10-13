import UIKit
import SafariServices

class TributeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: (10/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        dismissButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 90/375).isActive = true
        dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 40/90).isActive = true
        
        view.addSubview(claireLabel)
        claireLabel.anchor(top: dismissButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (30/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        claireLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 315/375).isActive = true
        claireLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        claireLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 180/667).isActive = true
        
        view.addSubview(claireDescriptionLabel)
        claireDescriptionLabel.anchor(top: claireLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        claireDescriptionLabel.widthAnchor.constraint(equalTo: claireLabel.widthAnchor, multiplier: 1).isActive = true
        claireDescriptionLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 50/667).isActive = true
        claireDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(claireImage)
         claireImage.anchor(top: claireDescriptionLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (20/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        claireImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 200/375).isActive = true
        claireImage.heightAnchor.constraint(equalTo: claireImage.widthAnchor, multiplier: 100/200).isActive = true
        claireImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(foundationLinkButton)
        foundationLinkButton.anchor(top: claireImage.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (30/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        foundationLinkButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 250/375).isActive = true
        foundationLinkButton.heightAnchor.constraint(equalTo: foundationLinkButton.widthAnchor, multiplier: 30/250).isActive = true
        foundationLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(youtubeLinkButton)
        youtubeLinkButton.anchor(top: foundationLinkButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        youtubeLinkButton.widthAnchor.constraint(equalTo: foundationLinkButton.widthAnchor, multiplier: 1).isActive = true
        youtubeLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        youtubeLinkButton.heightAnchor.constraint(equalTo: foundationLinkButton.heightAnchor, multiplier: 1).isActive = true
        
        if UIScreen.main.bounds.size.width <= 320 {
            claireLabel.font = UIFont.systemFont(ofSize: 16.0)
            claireDescriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
            foundationLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            youtubeLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            dismissButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
    }
    
    let claireLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Please donate to The Claire's Place Foundation to support families with members suffering from cystic fibrosis. \n\n Rest in Peace Claire Wineland \n (4/10/1997 - 9/2/2018 : 21 years)"
        return label
    }()
    
    let claireDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Activist, author, public speaker, cystic fibrosis fighter"
        return label
    }()
    
    let claireImage: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "tribute_pic")
        return iv
    }()
    
    let foundationLinkButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("The Claire's Place Foundation", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(foundationLinkTapped), for: .touchUpInside)
        return button
    }()
    
    let youtubeLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Claire's Youtube Channel", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(youtubeLinkTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func foundationLinkTapped() {
        let url = NSURL(string: "http://clairesplacefoundation.org/")! as URL
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    @objc func youtubeLinkTapped() {
        let url = NSURL(string: "https://www.youtube.com/channel/UCTw8xGVrk4FTAJwMG6mw22w")! as URL
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    let dismissButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
