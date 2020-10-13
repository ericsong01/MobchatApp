import UIKit

class TermsAndConditionsViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        navigationItem.title = "Terms and Conditions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissView))
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollView.addSubview(viewInScrollView)
        viewInScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        viewInScrollView.anchor(top: scrollView.topAnchor, left:  scrollView.leftAnchor, bottom:  scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.isScrollEnabled = true
        return sv
    }()
    
    let viewInScrollView: TextView = {
        let view = TextView()
        view.backgroundColor = .white
        return view
    }()
    
}

class TextView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(termsTextView)
        if UIScreen.main.bounds.height <= 586 {
            termsTextView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor
                , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1210)
        } else if UIScreen.main.bounds.height <= 736 {
            termsTextView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor
                , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1250)
        } else {
            termsTextView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor
                , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1500)
        }
        
        if UIScreen.main.bounds.height <= 586 {
            termsTextView.font = UIFont.systemFont(ofSize: 10)
        } else if UIScreen.main.bounds.height == 736 { // iphone 6+, 6s+, 7+, 8+
            termsTextView.font = UIFont.systemFont(ofSize: 11)
        } else if UIScreen.main.bounds.height >= 812 {
            termsTextView.font = UIFont.systemFont(ofSize: 13)
        }
    }
    
    let termsTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 11)
        tv.text = "MobChat App End User License Agreement\n\nThis End User License Agreement (“Agreement”) is between you and MobChat and governs use of this app made available through the Apple App Store. By installing the MobChat App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the MobChat App.\n\nIn order to ensure MobChat provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content. If you see inappropriate content, please use the “Report as offensive” feature found under each post.\n\n1. Parties\nThis Agreement is between you and MobChat only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. MobChat, not Apple, is solely responsible for the MobChat App and its content.\n\n2. Privacy\nMobChat may collect and use information about your usage of the MobChat App, including certain types of information from and about your device. MobChat may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the MobChat App.\n\n3. Limited License\nMobChat grants you a limited, non-exclusive, non-transferable, revocable license to use theMobChat App for your personal, non-commercial purposes. You may only use theMobChat App on Apple devices that you own or control and as permitted by the App Store Terms of Service.\n\n4. Age Restrictions\nBy using the MobChat App, you represent and warrant that (a) you are 17 years of age or older and you agree to be bound by this Agreement; (b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the MobChat App does not violate any applicable law or regulation. Your access to the MobChat App may be terminated without warning if MobChat believes, in its sole discretion, that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child’s use of the MobChat App, you agree to be bound by this Agreement in respect to your child’s use of the MobChat App.\n\n5. Objectionable Content Policy\nContent may not be submitted to MobChat, who will moderate all content and ultimately decide whether or not to post a submission to the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: (i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (v) gambling, including without limitation, any online casino, sports books, bingo or poker.\n\n6. Warranty\nMobChat disclaims all warranties about the MobChat App to the fullest extent permitted by law. To the extent any warranty exists under law that cannot be disclaimed, MobChat, not Apple, shall be solely responsible for such warranty.\n\n7. Maintenance and Support\nMobChat does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, MobChat, not Apple, shall be obligated to furnish any such maintenance or support.\n\n8. Product Claims\nMobChat, not Apple, is responsible for addressing any claims by you relating to the MobChat App or use of it, including, but not limited to: (i) any product liability claim; (ii) any claim that the MobChat App fails to conform to any applicable legal or regulatory requirement; and (iii) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims.\n\n9. Third Party Intellectual Property Claims\nMobChat shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the MobChat App. To the extent MobChat is required to provide indemnification by applicable law, MobChat, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the MobChat App or your use of it infringes any third party intellectual property right."
        return tv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


