import UIKit
import Firebase

class ReportUserViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    var user: User? {
        didSet {
            guard let username = user?.username else {return}
            navigationItem.title = "Report \(username)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(reportDetailsLabel)
        reportDetailsLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (20/667) * view.bounds.height, paddingLeft: (20/375) * view.bounds.height, paddingBottom: 0, paddingRight: (20/375) * view.bounds.height, width: 0, height:60)
        
        view.addSubview(reportDetailsTextView)
        if UIScreen.main.bounds.height <= 568 {
             reportDetailsTextView.anchor(top: reportDetailsLabel.bottomAnchor, left: reportDetailsLabel.leftAnchor, bottom: nil, right: reportDetailsLabel.rightAnchor, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        } else {
             reportDetailsTextView.anchor(top: reportDetailsLabel.bottomAnchor, left: reportDetailsLabel.leftAnchor, bottom: nil, right: reportDetailsLabel.rightAnchor, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        }
        
        view.addSubview(reportButton)
        reportButton.anchor(top: reportDetailsTextView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: (10/667) * view.bounds.height, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 30)
        reportButton.centerXAnchor.constraint(equalTo: reportDetailsTextView.centerXAnchor).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportDetailsTextView.becomeFirstResponder()
    }
    
    let reportDetailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Include details about offensive content, where offensive content was posted (in which chat or in profile picture) etc. Vague reports may not be investigated."
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var reportDetailsTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.delegate = self
        tv.layer.cornerRadius = 5
        return tv
    }()
    
    let reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Report", for: .normal)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        return button
    }()
    
    @objc func handleReport() {
        // Firebase calls and crap
        
        if reportDetailsTextView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            self.presentAlert(alert: "You must fill in report details")
            return
        }
        
        guard let username = self.user?.username else {return}
        let alertController = UIAlertController(title: "Report \(username)?", message: "If found guilty, reported user will be flushed and banned", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        let okAction = UIAlertAction(title: "Ok", style: .destructive) { (action) in
         
            guard let uid = self.user?.uid else {return}
            guard let reportingUserUID = Auth.auth().currentUser?.uid else {return}
            guard let reportDetails = self.reportDetailsTextView.text else {return}
            
            let ref = Database.database().reference()
            guard let childReportId = ref.child("reports").child("user_reports").childByAutoId().key else {return} 
            let reportDictionary = ["reportingUserUID": reportingUserUID, "reportedUserUID":uid, "reportDetails": reportDetails]
            ref.child("reports").child("user_reports").child(childReportId).updateChildValues(reportDictionary) { (error, ref) in
                
                if let error = error {
                    print ("Couldn't send report:", error)
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if Int((text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location) == NSNotFound {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count <= 300
        }
        return false
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
    
}
