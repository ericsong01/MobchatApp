import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class BioTextViewController: UIViewController, UITextViewDelegate {
    
    var bio: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        textView.delegate = self
        
        navigationItem.title = "Bio"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPressed))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black

        view.addSubview(textView)
        textView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: (3/667) * view.bounds.height, paddingLeft: (12.5/375) * view.bounds.width, paddingBottom: 0, paddingRight: (12.5/375) * view.bounds.width, width: 0, height: 0)
        
        
        view.addSubview(textViewSeparatorLine)
        textViewSeparatorLine.anchor(top: textView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        if UIScreen.main.bounds.width <= 320 {
            textView.font = UIFont.systemFont(ofSize: 15)
        }
        
        view.addSubview(textViewCharactersCount)
        textViewCharactersCount.anchor(top: textView.bottomAnchor, left: nil, bottom: nil, right: textView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 25)

        if bio != nil {
            textView.text = bio
            textView.sizeToFit()
        }
        
        let text = textView.text as String
        textViewCharactersCount.text = "\(200 - text.count)"
        
    }
    
    let textViewSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    @objc func doneTapped() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["bio":textView.text] as [String:AnyObject]
        
        Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print ("Couldn't update bio")
                return
            }
            
            globalBiography = self.textView.text
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.backgroundColor = UIColor.clear
        tv.isScrollEnabled = false
        return tv
    }()
    
    let textViewCharactersCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    // TextView Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewNotasChange(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
        
        let calHeight = arg.frame.size.height
        arg.frame = CGRect(x: 16, y: 40, width: self.textView.frame.width, height: calHeight)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
                
        let text = textView.text as String
        textViewCharactersCount.text = "\(200 - text.count)"
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if Int((text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location) == NSNotFound {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count <= 200
        }
        return false
    }
}
