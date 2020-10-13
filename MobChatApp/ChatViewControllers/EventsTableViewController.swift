import UIKit
import Firebase
import EventKit

protocol PresentEventPopUpProtocol: class {
    func presentEventPopUpViewController()
}

protocol PresentCalendarAlertProtocol: class {
    func presentCalendarAlert(title: String, description: String, date: Date)
}

protocol ExpandCellProtocol: class {
    func expandCell(for indexPath: IndexPath)
}

class EventsViewController: UIViewController, PresentCalendarAlertProtocol, ExpandCellProtocol, UITableViewDataSource, UITableViewDelegate {
    
    func expandCell(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            if notifications[indexPath.section].opened == true {
                notifications[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .automatic)
            } else {
                notifications[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .automatic)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.lightView.alpha = 1
        }, completion: nil)
    }
    
    let lightView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.alpha = 0
        view.backgroundColor = .white
        return view
    }()
    
    let eventsLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    var notificationsDictionary = [String:Notification]()
    var notifications = [Notification]()
    var conversation: Conversation? // TODO: Must set this when presenting
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(lightView)
        lightView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 10, paddingRight: 15, width: 0, height: 300)
        
        lightView.addSubview(eventsLabel)
        eventsLabel.anchor(top: lightView.topAnchor, left: lightView.leftAnchor, bottom: nil, right: lightView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 50)
        
        lightView.addSubview(tableView)
        tableView.anchor(top: eventsLabel.bottomAnchor, left: lightView.leftAnchor, bottom: lightView.bottomAnchor, right: lightView.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
        navigationItem.title = "Events"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add_event_button"), style: .plain, target: self, action: #selector(addEventTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_button"), style: .plain, target: self, action: #selector(dismissTapped))
        
        tableView.register(EventsTableViewCell.self, forCellReuseIdentifier: "eventsTableViewCellId")
        tableView.register(DescriptionTableViewCell.self, forCellReuseIdentifier: "descriptionTableViewCellId")
        
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        view.backgroundColor = .white
        
        observeEventNotifications()
        
    }
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func observeEventNotifications() {
        
        let ref = Database.database().reference()
        guard let convoId = self.conversation?.conversationId else {return}
        ref.child("conversations_notifications").child(convoId).observe(.childAdded, with: { (snapshot) in
            let notificationId = snapshot.key
            guard let notificationDict = snapshot.value as? [String:AnyObject] else {return}
            let notification = Notification(dictionary: notificationDict)
            self.notificationsDictionary[notificationId] = notification
            self.attemptReloadOfEventTableView()
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.notificationsDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfEventTableView()
        }, withCancel: nil)
    }
    
    func removeValue(for value: String) {
        self.notificationsDictionary.removeValue(forKey: value)
        self.attemptReloadOfEventTableView()
    }
    
    func attemptReloadOfEventTableView() {
        self.notifications = Array(self.notificationsDictionary.values)
        
        self.notifications.sort(by: { (n1, n2) -> Bool in
            return (n1.notificationDate?.intValue)! < (n2.notificationDate?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func addEventTapped() {
        
        if notifications.count >= 10 {
            presentAlert(alert: "You can only set up to 10 event reminders at once. Delete one to add another.")
            return
        }
        
        let eventPopUpViewController = AddEventPopUpViewController()
        eventPopUpViewController.conversation = self.conversation
        eventPopUpViewController.modalTransitionStyle = .crossDissolve
        eventPopUpViewController.modalPresentationStyle = .overCurrentContext
        self.present(eventPopUpViewController, animated: true, completion: nil)
        
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        } else {
            return 75
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notifications[section].opened == true {
            return 2
        }
        return 1
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventsTableViewCellId", for: indexPath) as! EventsTableViewCell
            let notification = notifications[indexPath.section]
            cell.eventTitleLabel.text = notification.notificationTitle
            cell.expandCellDelegate = self
            
            if let second = notification.notificationDate?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: second)
                let dateFormatters = DateFormatter()
                dateFormatters.dateFormat = "MM/dd"
                if let numberDate = dateFormatters.string(for: timestampDate) {
                    cell.eventTimeLabel.text = numberDate
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionTableViewCellId", for: indexPath) as! DescriptionTableViewCell
            cell.calendarTransitionDelegate = self
            let notification = notifications[indexPath.section]
            cell.notification = notification
            return cell
        }
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.section]
        guard let notificationId = notification.notificationId, let myUsername = globalUsername, let title = notification.notificationTitle, let conversationId = self.conversation?.conversationId, let uid = Auth.auth().currentUser?.uid else {return}
        
        let ref = Database.database().reference()
        
        guard let logKey = ref.child("highlights_log").child(conversationId).childByAutoId().key else {return}
        let log = ["\(myUsername) deleted '\(title)' from events \u{1F5C2}":uid]
        
        let values = ["/conversations_notifications/\(conversationId)/\(notificationId)":NSNull(), "/highlights_log/\(conversationId)/\(logKey)":log] as [String : AnyObject]
        
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                print ("Failed to delete event reminder:", error as Any)
                return
            }
            
            self.removeValue(for:  notificationId)
        }
    }
    
    func presentCalendarAlert(title: String, description: String, date: Date) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            if !granted {
                print ("not allowed")
                DispatchQueue.main.async(execute: {
                    let alertController = UIAlertController(title: "Access to Calendar is Restricted", message: "To re-enable, please go to Settings and turn on Calendar Settings for this app", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { action in
                        if let aString = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(aString, options: [:], completionHandler: nil)
                        }
                    })
                    let actionOK = UIAlertAction(title: "Back", style: .default, handler: { action in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(settingsAction)
                    alertController.addAction(actionOK)
                    alertController.preferredAction = settingsAction
                    self.present(alertController, animated: true)
                })
            } else {
                DispatchQueue.main.async {
                    let calendarAlertVC = UIAlertController(title: "Add \(title) to calendar?", message: "", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                        
                        let event = EKEvent(eventStore: store)
                        event.title = title
                        event.startDate = date
                        event.endDate = date
                        event.notes = description
                        event.calendar = store.defaultCalendarForNewEvents
                        do {
                            try store.save(event, span: .thisEvent)
                        } catch let e as NSError {
                            print ("error saving", e as Any)
                            self.presentAlert(alert: "Error saving \(title) to calendar")
                            return
                        }
                        
                        let transitionAlertVC = UIAlertController(title: "Successfully Added Event", message: "Go to calendar app to set up notification?", preferredStyle: .alert)
                        let transitionOkAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            let interval = date.timeIntervalSinceReferenceDate
                            if let url = URL(string: "calshow:\(interval)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                            transitionAlertVC.dismiss(animated: true, completion: nil)
                        })
                        
                        let transitionCancelAction = UIAlertAction(title: "No", style: .default) { (action) in
                            transitionAlertVC.dismiss(animated: true, completion: nil)
                        }
                        
                        transitionAlertVC.addAction(transitionOkAction)
                        transitionAlertVC.addAction(transitionCancelAction)
                        
                        calendarAlertVC.dismiss(animated: true, completion: nil)
                        self.present(transitionAlertVC, animated: true, completion: nil)
                        
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                        calendarAlertVC.dismiss(animated: true, completion: nil)
                    }
                    
                    calendarAlertVC.addAction(okAction)
                    calendarAlertVC.preferredAction = okAction
                    calendarAlertVC.addAction(cancelAction)
                    
                    self.present(calendarAlertVC, animated: true, completion: nil)
                }
                
            }
        }
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
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
