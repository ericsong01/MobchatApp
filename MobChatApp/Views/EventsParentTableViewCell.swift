
import UIKit
import EventKit
import Firebase

protocol HandleSwitchLeaveJoinChatButtonsProtocol: class {
   func hideButtons()
   func showButtons()
   func turnNotificationSwitchOn()
   func turnNotificationSwitchOff()
   func disableNotificationSwitch()
   func enableNotificationSwitch()
}

protocol ChangingLeaveJoinChatButtonsProtocol: class {
   func joinToLeaveMobButtonChange()
   func leaveToJoinMobButtonChange()
}

class EventsParentTableViewCell: UITableViewCell, ChangingLeaveJoinChatButtonsProtocol, HandleSwitchLeaveJoinChatButtonsProtocol {

   func hideButtons() {
      leaveChatButton.isHidden = true
      joinChatButton.isHidden = true
      notificationSwitchLabel.isHidden = true
      notificationSwitch.isHidden = true
   }
   
   func showButtons() {
      leaveChatButton.isHidden = false
      joinChatButton.isHidden = false
      notificationSwitchLabel.isHidden = false
      notificationSwitch.isHidden = false
   }
   
   func disableNotificationSwitch() {
      DispatchQueue.main.async {
         self.notificationSwitch.isEnabled = false
      }
   }
   
   func enableNotificationSwitch() {
      DispatchQueue.main.async {
         self.notificationSwitch.isEnabled = true
      }
   }
   
   var conversation: Conversation?
   
   weak var leaveJoinChatDelegate: LeaveJoinChatProtocol!
   
   var isCreatorOfChat: Bool?
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: .default, reuseIdentifier: reuseIdentifier)
      
      backgroundColor = UIColor.clear
      selectionStyle = .none
      
      addSubview(notificationSwitchLabel)
      notificationSwitchLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 140, height: 30)
      
      addSubview(notificationSwitch)
      notificationSwitch.anchor(top: nil, left: notificationSwitchLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 70, height: 30)
      notificationSwitch.centerYAnchor.constraint(equalTo: notificationSwitchLabel.centerYAnchor).isActive = true
      
      addSubview(leaveChatButton)
      addSubview(joinChatButton)
      leaveChatButton.anchor(top: notificationSwitch.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 50)
      joinChatButton.anchor(top: notificationSwitch.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 50)
      
   }
   
   lazy var notificationSwitch: UISwitch = {
      let control = UISwitch()
      control.isHidden = false
      control.addTarget(self, action: #selector(notificationsOn), for: .valueChanged)
      return control
   }()
   
   @objc func notificationsOn() {
      
      guard let uid = Auth.auth().currentUser?.uid else {return}
      guard let conversationId = self.conversation?.conversationId else {return}
      let ref = Database.database().reference()
      
      if notificationSwitch.isOn {
         print ("switch is being turned on")
         
         let activateValues = ["/users/\(uid)/conversations_notifications_active/\(conversationId)":1]
         ref.updateChildValues(activateValues) { (error, ref) in
            if let error = error {
               print ("Couldnt' update active conversations:", error)
               return
            }
         }
         
      } else {
         print ("switch is being turned off")
         let deactivateValues = ["/users/\(uid)/conversations_notifications_active/\(conversationId)":NSNull()]
         ref.updateChildValues(deactivateValues) { (error, ref) in
            if let error = error {
               print ("Couldn't deactivate conversations:", error)
               return
            }
         }
      }
   }
   
   let notificationSwitchLabel: UILabel = {
      let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
      label.textColor = UIColor.darkGray
      label.isHidden = false
      label.text = "Enable Notifications"
      return label
   }()
   
   func turnNotificationSwitchOn() {
      notificationSwitch.isOn = true
   }
   
   func turnNotificationSwitchOff() {
      notificationSwitch.isOn = false 
   }

   // MARK: Leave and Join Chat Buttons
   
   lazy var leaveChatButton: UIButton = {
      let button = UIButton()
      button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
      button.addTarget(self, action: #selector(leaveChatTapped), for: .touchUpInside)
      button.addTarget(self, action: #selector(leaveChatButtonTouchDown), for: .touchDown)
      button.addTarget(self, action: #selector(leaveChatTouchUpOutside), for: .touchUpOutside)
      button.addTarget(self, action: #selector(leaveChatTouchDragExit), for: .touchDragExit)
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
      button.tintColor = UIColor.black
      button.setTitle("Leave Mob", for: .normal)
      button.setBackgroundImage(UIImage(named: "orange_gradient"), for: .normal)
      button.clipsToBounds = true
      button.layer.cornerRadius = 5
      button.titleLabel?.adjustsFontSizeToFitWidth = true
      button.adjustsImageWhenHighlighted = false
      button.isHidden = true
      button.isEnabled = false
      return button
   }()
   
   @objc func leaveChatTouchDragExit() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
         self.leaveChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   @objc func leaveChatButtonTouchDown() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
         self.leaveChatButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }, completion: nil)
   }
   
   @objc func leaveChatTouchUpOutside() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
         self.leaveChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   @objc func leaveChatTapped() {
      print ("leave chat tapped")
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
         self.leaveChatButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }) { (_) in
         UIView.animate(withDuration: 0.3, animations: {
            self.leaveChatButton.transform = CGAffineTransform.identity // Reset to default size
         })
         self.leaveJoinChatDelegate.leaveChat()
      }
   }
   
   lazy var joinChatButton: UIButton = {
      let button = UIButton()
      button.titleLabel?.font = UIFont(name: "Rockwell", size: 20)
      button.addTarget(self, action: #selector(joinChatTapped), for: .touchUpInside)
      button.addTarget(self, action: #selector(joinChatButtonTouchDown), for: .touchDown)
      button.addTarget(self, action: #selector(joinChatTouchUpOutside), for: .touchUpOutside)
      button.addTarget(self, action: #selector(joinChatTouchDragExit), for: .touchDragExit)
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
      button.tintColor = UIColor.black
      button.setTitle("Join Mob", for: .normal)
      button.setBackgroundImage(UIImage(named: "purple_gradient"), for: .normal)
      button.clipsToBounds = true
      button.layer.cornerRadius = 5
      button.titleLabel?.adjustsFontSizeToFitWidth = true
      button.adjustsImageWhenHighlighted = false
      button.isHidden = true
      button.isEnabled = false
      return button
   }()
   
   
   @objc func joinChatTouchDragExit() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
         self.joinChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   @objc func joinChatButtonTouchDown() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
         self.joinChatButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }, completion: nil)
   }
   
   @objc func joinChatTouchUpOutside() {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.allowUserInteraction, .curveEaseOut], animations: {
         self.joinChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   @objc func joinChatTapped() {
      print ("join chat tapped")
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
         self.joinChatButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }) { (_) in
         UIView.animate(withDuration: 0.3, animations: {
            self.joinChatButton.transform = CGAffineTransform.identity // Reset to default size
         })
         self.leaveJoinChatDelegate.joinChat()
      }
   }
   
   var deviceHasNotificationsActivated: Bool?
   
   func joinToLeaveMobButtonChange() {
      joinChatButton.isHidden = true
      joinChatButton.isEnabled = false
      leaveChatButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .curveEaseOut, animations: {
         
         // Prevent bug where user has app notifications disabled but the switch turns enabled
         if self.deviceHasNotificationsActivated ?? false {
            self.notificationSwitch.isEnabled = true
            self.notificationSwitch.isOn = true
         } else {
            self.notificationSwitch.isEnabled = false
            // Don't turn the notification switch anywhere if the device doesn't have push activated
         }
         
         self.leaveChatButton.isHidden = false
         self.leaveChatButton.isEnabled = true
         self.leaveChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   func leaveToJoinMobButtonChange() {
      leaveChatButton.isHidden = true
      leaveChatButton.isEnabled = false
      joinChatButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .curveEaseOut, animations: {
         
         if self.deviceHasNotificationsActivated ?? false {
            self.notificationSwitch.isEnabled = false
            self.notificationSwitch.isOn = false
         } else {
            // Do nothing since notifications are not activated 
         }
         
         self.joinChatButton.isHidden = false
         self.joinChatButton.isEnabled = true
         self.joinChatButton.transform = CGAffineTransform.identity
      }, completion: nil)
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
}

