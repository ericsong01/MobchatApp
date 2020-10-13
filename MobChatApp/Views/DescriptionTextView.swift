import UIKit

class DescriptionTextView: UITextView {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter introduction text here. Describe what will be discussed in this chat. 400 character limit. Please keep the line count under 15."
        label.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        label.numberOfLines = 0 
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isScrollEnabled = true
        isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeholderLabel)
        
        if UIScreen.main.bounds.height == 568 {
            placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 250, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 13)
            font = UIFont.systemFont(ofSize: 13)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        } else if UIScreen.main.bounds.height == 667 { // iphone 6+, 6s+, 7+, 8+, 6,7
            placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 300, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 15)
            font = UIFont.systemFont(ofSize: 15)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
        } else if UIScreen.main.bounds.height >= 736 {
            placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 300, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 17)
            font = UIFont.systemFont(ofSize: 17)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden =  !self.text.isEmpty // If the text is not empty, we hide the placeholder label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// This is used in the EditChatInfoVC 
class DescriptionTextView2: UITextView {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter introduction text here. Describe what will be discussed in this chat. 400 character limit. Please keep the line count under 15."
        label.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isScrollEnabled = true
        isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        if self.text != "" || self.text != nil {
            placeholderLabel.isHidden = true
        }
        
        addSubview(placeholderLabel)
        
        if UIScreen.main.bounds.height <= 568 {
            placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 270, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 14)
            font = UIFont.systemFont(ofSize: 14)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        } else if UIScreen.main.bounds.height == 667 { // iphone 6+, 6s+, 7+, 8+
             placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 300, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 15)
            font = UIFont.systemFont(ofSize: 15)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
        } else if UIScreen.main.bounds.height >= 736 {
            placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 300, height: 0)
            placeholderLabel.font = UIFont.systemFont(ofSize: 17)
            font = UIFont.systemFont(ofSize: 17)
            placeholderLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden =  !self.text.isEmpty // If the text is not empty, we hide the placeholder label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
