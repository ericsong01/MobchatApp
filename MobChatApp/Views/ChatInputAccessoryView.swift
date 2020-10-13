
import UIKit

protocol ChatInputAccessoryViewDelegate {
    func didSend(for text: String)
    func uploadMedia()
}

class ChatInputAccessoryView: UIView, UITextFieldDelegate {
    
    var delegate: ChatInputAccessoryViewDelegate!
    
    func clearChatTextField() {
        chatTextField.text = nil
    }
    
    let uploadImageViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "add_media")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleUploadImageTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUploadImageTapped() {
        print ("Handle upload imagE")
        delegate?.uploadMedia()
    }
    
    let chatTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Enter Message",
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.backgroundColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
        tf.textColor = .white
        tf.tintColor = .white
        return tf
    }()
    
    fileprivate let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside )
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chatTextField.delegate = self
        
        addSubview(uploadImageViewButton)
        uploadImageViewButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        
        //1
        autoresizingMask = .flexibleHeight
        
        backgroundColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
        
        if UIScreen.main.bounds.height < 812 {
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        } else if UIScreen.main.bounds.height == 812 {
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        } else if UIScreen.main.bounds.height == 896 {
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        addSubview(chatTextField)
        
        //3
        
        chatTextField.anchor(top: topAnchor, left: uploadImageViewButton.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 40)
        
        setupLineSeparatorView()
    }
    
    //2
    override var intrinsicContentSize: CGSize {
        return .zero // Sizes the input area based on the size of the text view
    }
    
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.darkGray
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSend() {
        guard let chatText = chatTextField.text else {return}
        delegate?.didSend(for: chatText)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 200
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
