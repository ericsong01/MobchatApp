import UIKit
import Firebase

class AddEventPopUpViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.notificationTitleTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonHasBeenTapped = false
    }
    
    private var datePicker: UIDatePicker?
    
    var conversation: Conversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationDescriptionTextField.delegate = self
        notificationTitleTextField.delegate = self
        notificationDateTextField.delegate = self
        
        view.addSubview(dimView)
        dimView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(lightView)
        lightView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: (300/667) * view.bounds.height, paddingRight: 15, width: 0, height: 280)
        lightView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        lightView.addSubview(doneButton)
        doneButton.anchor(top: nil, left: lightView.centerXAnchor, bottom: lightView.bottomAnchor, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 20, paddingRight: 0, width: 60, height: 40)
        
        lightView.addSubview(notificationDateTextField)
        notificationDateTextField.anchor(top: nil, left: lightView.leftAnchor, bottom: doneButton.topAnchor, right: lightView.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 40)
        
        lightView.addSubview(notificationDescriptionTextField)
        notificationDescriptionTextField.anchor(top: nil, left: notificationDateTextField.leftAnchor, bottom: notificationDateTextField.topAnchor, right: notificationDateTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 40)
    
        lightView.addSubview(notificationTitleTextField)
        notificationTitleTextField.anchor(top: nil, left: notificationDateTextField.leftAnchor, bottom: notificationDescriptionTextField.topAnchor, right: notificationDateTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 40)
        
        lightView.addSubview(eventReminderLabel)
        eventReminderLabel.anchor(top: nil, left: nil, bottom: notificationTitleTextField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 15, paddingRight: 0, width: 200, height: 30)
        eventReminderLabel.centerXAnchor.constraint(equalTo: lightView.centerXAnchor).isActive = true
        
        lightView.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: nil, right: lightView.centerXAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 70, height: 40)
        cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        notificationDateTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)

    }
    
    var standardizedDate: String?
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        notificationDateTextField.text = dateFormatter.string(from: datePicker.date)
        print ("realDate:", dateFormatter.string(from: datePicker.date))
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        standardizedDate = dateFormatter.string(from: datePicker.date)
        print ("utcDate:", standardizedDate)
    }
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 1
        return view
    }()
    
    let lightView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.alpha = 1
        view.backgroundColor = .white
        return view
    }()
    
    let eventReminderLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "Event Reminder"
        label.textColor = UIColor(red: 0.4706, green: 0.0000, blue: 0.8902, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.tintColor = UIColor.white
        button.setTitle("Done", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Cancel", for: .normal)
        button.setBackgroundImage(UIImage(named: "orange_gradient"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(cancelButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(cancelButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(cancelButtonTouchDragExit), for: .touchDragExit)
        return button
    }()
    
    @objc func cancelButtonTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.cancelButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.cancelButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.dismissView()
            })
        }
    }
    
    @objc func cancelButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.cancelButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    @objc func cancelButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.cancelButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func cancelButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.cancelButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    let descriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let notificationTitleTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 0
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Event Title"
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.leftView = spacerView
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.tintColor = .black
        return tf
    }()
    
    let notificationDescriptionTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 1
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.leftView = spacerView
        tf.placeholder = "Display Description"
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.clearButtonMode = .whileEditing
        tf.tintColor = .black
        return tf
    }()
    
    let notificationDateTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 2
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        tf.leftViewMode = UITextField.ViewMode.always
        tf.leftView = spacerView
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Date of Event"
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.purple.cgColor
        tf.tintColor = .black
        return tf
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(doneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(doneButtonTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(doneButtonTouchDragExit), for: .touchDragExit)
        button.titleLabel?.font = UIFont(name: "Rockwell", size: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.tintColor = UIColor.white
        button.setTitle("Done", for: .normal)
        button.setBackgroundImage(UIImage(named: "purple_gradient"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    @objc func doneButtonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.doneButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    @objc func doneButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.doneButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func doneButtonTouchDragExit() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.doneButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    var buttonHasBeenTapped = false
    
    @objc func doneTapped() {
        print ("done tapped")
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.doneButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.doneButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                guard self.buttonHasBeenTapped != true else {return} // Prevent multiple database registers
                
                self.buttonHasBeenTapped = true
                
                let ref = Database.database().reference()
                
                guard let conversationId = self.conversation?.conversationId else {return}
                guard let title = self.notificationTitleTextField.text, let date = self.notificationDateTextField.text, let description = self.notificationDescriptionTextField.text, let myUsername = globalUsername, let uid = Auth.auth().currentUser?.uid else {return}
                
                if !title.trimmingCharacters(in: .whitespaces).isEmpty, !date.trimmingCharacters(in: .whitespaces).isEmpty, !description.trimmingCharacters(in: .whitespaces).isEmpty {
                    guard let notificationId =  ref.child("conversations_notifications").child(conversationId).childByAutoId().key else {return}
                    guard let standardizedDate = self.standardizedDate else {return}
                    print ("title:", title, "description:", description)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yy HH:mm"
                    let convertedDate = dateFormatter.date(from: standardizedDate)?.timeIntervalSince1970
                    
                    guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
                    let log = [uid:"\(myUsername) added '\(title)' to events \u{1F4C5}"]
                    
                    let values : [String:AnyObject] = ["notificationId": notificationId,"notificationTitle": title, "notificationDate": convertedDate as Any, "notificationDescription": description] as [String:AnyObject]
                    let notificationValues = ["/conversations_notifications/\(conversationId)/\(notificationId)":values, "/highlights_log/\(conversationId)/\(logKey)":log] as [String : AnyObject]
                    
                    ref.updateChildValues(notificationValues) { (error, ref) in
                        
                        if let error = error {
                            print ("Couldn't update reminders:", error)
                        }

                        self.dismissView()
                    }
                } else {
                    self.buttonHasBeenTapped = false
                    self.presentAlert(alert: "All fields must be filled in")
                }
            })
        }
    }
    
    func dismissView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 1
            self.lightView.alpha = 1
        }) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        if textField == notificationTitleTextField {
            let newLength = text.count + string.count - range.length
            return newLength <= 25
        } else if textField == notificationDescriptionTextField {
            let newLength = text.count + string.count - range.length
            return newLength <= 50
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
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
