import UIKit

class CreditsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: ((20/667) * view.bounds.height), paddingLeft: (10/375) * view.bounds.width, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        dismissButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 90/375).isActive = true
        dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor, multiplier: 40/90).isActive = true
        
        view.addSubview(creditsLabel)
        creditsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/375).isActive = true
        creditsLabel.heightAnchor.constraint(equalTo: creditsLabel.widthAnchor, multiplier: 275/300).isActive = true
        creditsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        creditsLabel.anchor(top: dismissButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (60/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(creditsTitle)
        creditsTitle.anchor(top: nil, left: nil, bottom: creditsLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        creditsTitle.centerXAnchor.constraint(equalTo: creditsLabel.centerXAnchor).isActive = true
        
         view.addSubview(emailLabel)
         emailLabel.anchor(top: creditsLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (20/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
         emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/375).isActive = true
         emailLabel.heightAnchor.constraint(equalTo: emailLabel.widthAnchor, multiplier: 150/300).isActive = true
         emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if UIScreen.main.bounds.size.width <= 320 {
            dismissButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            creditsLabel.font = UIFont.systemFont(ofSize: 12.0)
            emailLabel.font = UIFont.systemFont(ofSize: 12.0)
        } else if UIScreen.main.bounds.size.height >= 667 {
            creditsLabel.font = UIFont.systemFont(ofSize: 14.0)
            emailLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
    }
    
    let creditsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Chris (CodeWithChris): Thanks for motivating me to start coding and for providing excellent, beginner tutorials that allowed me to overcome the hump \n\n Brian (Lets Build That App): Thanks for teaching me the foundations of databases and more complex real-time apps \n\n Icons8 (Mac app): App Icon, Settings Icon, Tab Bar Icons, Navigation bar Icons /n/n SmashIcons from www.flaticon.com: + Image button icon"
        return label
    }()
    
    let creditsTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Credits"
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
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email esong2288@gmail.com or post at @mobchatsupport on Facebook for info on donated funds, bugs, desired features, questions etc. Please excuse the bugs, I'm still learning :)"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
