import UIKit
import Firebase
import UserNotifications
import AVFoundation
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
                
        attemptRegisterForNotifications(application: application)
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = MainTabBarController()
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print ("Registered with FCM with token:", fcmToken)
        
        // Updates the topic subscriptions when the fcmToken is changed 
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).updateChildValues(["fcmToken":fcmToken]) { (error, ref) in
            
            if let error = error {
                print ("Error updating the new fcmToken:", error)
                return
            }
            
            var dict = [String:Int]()
            Database.database().reference().child("users").child(uid).child("conversations_notifications_active").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
                
                for (key, _) in dictionary {
                    dict[key] = 1
                }
                Database.database().reference().child("users").child(uid).child("conversations_notifications_active").removeValue(completionBlock: { (error, ref) in
                    
                    if let error = error {
                        print ("Error deleting the active convos after updating the fcmToken:", error)
                        return
                    }
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {// Delaying it makes it so the chat is unsubcribed then subcribed again in the right order 
                        Database.database().reference().child("users").child(uid).child("conversations_notifications_active").updateChildValues(dict)
                    })
                    
                })
                
            }
            
        }
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let state = UIApplication.shared.applicationState
        if state == .background {
            let systemSoundID: SystemSoundID = 1007
            // to play sound
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let conversationId = userInfo["conversationId"] as? String {
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            
            Database.database().reference().child("conversations").child(conversationId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
                let conversation = Conversation(dictionary: dictionary)
                
                if let mainTabBarController = self.window?.rootViewController as? MainTabBarController {
                    
                    if mainTabBarController.selectedIndex == 1 { // We are on the search controller
                        if self.window?.visibleViewController is SearchConversationController {
                            mainTabBarController.selectedIndex = 0
                        } else if self.window?.visibleViewController is ChatLogController {
                            let chatLogController = self.window?.visibleViewController as? ChatLogController
                            if chatLogController?.conversationId == conversationId {
                                return // Don't continue, because we are already on the right conversation
                            } else {
                                // Dismiss the current chat log, so that we can push the next one
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    searchConvoController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is ChatInfoTableViewController {
                            // Check if it is for the right convo or not
                            let chatInfoViewController = self.window?.visibleViewController as? ChatInfoTableViewController
                            if chatInfoViewController?.conversation?.conversationId == conversationId {
                                chatInfoViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    chatInfoViewController?.dismiss(animated: true, completion: nil)
                                    searchConvoController.popToRootViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is EditChatInfoViewController {
                            let editChatInfoViewController =  self.window?.visibleViewController as? EditChatInfoViewController
                            if editChatInfoViewController?.conversationId == conversationId {
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else { // Not in the right convo
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    searchConvoController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is ChatLogBioViewController {
                            let chatLogBioViewController = self.window?.visibleViewController as? ChatLogBioViewController
                            guard let fromChatLogController = chatLogBioViewController?.fromTableViewController else {return}
                            if fromChatLogController { // bioVC pulled up from chatInfoTBVC
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    searchConvoController.popViewController(animated: true)
                                }
                            } else {
                                mainTabBarController.selectedIndex = 0
                                chatLogBioViewController?.navigationController?.popToRootViewController(animated: true)
                            }
                        } else if self.window?.visibleViewController is ReportUserViewController {
                            let reportUserViewController = self.window?.visibleViewController as? ReportUserViewController
                            reportUserViewController?.navigationController?.popViewController(animated: true)
                            if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                mainTabBarController.selectedIndex = 0
                                searchConvoController.popToRootViewController(animated: true)
                            }
                            // Fix this her
                        } else if self.window?.visibleViewController is KickUsersViewController {
                            // Check if it is for the right convo or not
                            let kickUsersViewController = self.window?.visibleViewController as? KickUsersViewController
                            if kickUsersViewController?.conversation?.conversationId == conversationId {
                                kickUsersViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    kickUsersViewController?.dismiss(animated: true, completion: nil)
                                    searchConvoController.popToRootViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is ReportChatViewController {
                            // Check if it is for the right convo or not
                            let reportChatViewController = self.window?.visibleViewController as? ReportChatViewController
                            if reportChatViewController?.conversationId == conversationId {
                                reportChatViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    reportChatViewController?.dismiss(animated: true, completion: nil)
                                    searchConvoController.popToRootViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is EventsViewController {
                            // Check if it is for the right convo or not
                            let eventsViewController = self.window?.visibleViewController as? EventsViewController
                            if eventsViewController?.conversation?.conversationId == conversationId {
                                eventsViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let searchConvoController = mainTabBarController.viewControllers?[1] as? UINavigationController {
                                    mainTabBarController.selectedIndex = 0
                                    eventsViewController?.dismiss(animated: true, completion: nil)
                                    searchConvoController.popToRootViewController(animated: true)
                                }
                            }
                        }
                        // End of checking for cases where tab bar is on search controller
                    } else if mainTabBarController.selectedIndex == 0 { // We are on the messages controller
                        if self.window?.visibleViewController is MessagesController {
                            // Do nothing
                        } else if self.window?.visibleViewController is CreateNewConvoController {
                            mainTabBarController.presentedViewController?.dismiss(animated: true, completion: nil)
                        } else if self.window?.visibleViewController is ChatLogController {
                            let chatLogController = self.window?.visibleViewController as? ChatLogController
                            if chatLogController?.conversationId == conversationId {
                                return // Don't continue, because we are already on the right conversation
                            } else {
                                // Dismiss the current chat log, so that we can push the next one
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is ChatInfoTableViewController {
                            // Determine if the info view controller has the right convoId
                            let chatInfoViewController = self.window?.visibleViewController as? ChatInfoTableViewController
                            if chatInfoViewController?.conversation?.conversationId == conversationId {
                                chatInfoViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    chatInfoViewController?.dismiss(animated: true, completion: nil)
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is EditChatInfoViewController {
                            let editChatInfoViewController =  self.window?.visibleViewController as? EditChatInfoViewController
                            if editChatInfoViewController?.conversationId == conversationId {
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else { // Not in the right convo
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is ChatLogBioViewController {
                            let chatLogBioViewController = self.window?.visibleViewController as? ChatLogBioViewController
                            guard let fromChatLogController = chatLogBioViewController?.fromTableViewController else {return}
                            print (fromChatLogController)
                            if fromChatLogController { // bioVC pulled up from chat log
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    messagesController.popViewController(animated: true)
                                }
                            } else {
                                chatLogBioViewController?.navigationController?.popToRootViewController(animated: true)
                            }
                        } else if self.window?.visibleViewController is ReportUserViewController {
                            let reportUserViewController = self.window?.visibleViewController as? ReportUserViewController
                            reportUserViewController?.navigationController?.popViewController(animated: true)
                            if let searchConvoController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                searchConvoController.popToRootViewController(animated: true)
                            }
                        } else if self.window?.visibleViewController is ReportChatViewController {
                            let reportChatViewController = self.window?.visibleViewController as? ReportChatViewController
                            if reportChatViewController?.conversationId == conversationId {
                                reportChatViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    reportChatViewController?.dismiss(animated: true, completion: nil)
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is EventsViewController {
                            let eventsViewController = self.window?.visibleViewController as? EventsViewController
                            if eventsViewController?.conversation?.conversationId == conversationId {
                                eventsViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    eventsViewController?.dismiss(animated: true, completion: nil)
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        } else if self.window?.visibleViewController is KickUsersViewController {
                            let kickUsersViewController = self.window?.visibleViewController as? KickUsersViewController
                            if kickUsersViewController?.conversation?.conversationId == conversationId {
                                kickUsersViewController?.dismiss(animated: true, completion: nil)
                                return
                            } else {
                                // Not in the right convo
                                if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                                    kickUsersViewController?.dismiss(animated: true, completion: nil)
                                    messagesController.popViewController(animated: true)
                                }
                            }
                        }
                    } else if mainTabBarController.selectedIndex == 2 {
                        if self.window?.visibleViewController is UserProfileController {
                            mainTabBarController.selectedIndex = 0
                        } else if self.window?.visibleViewController is EditUserProfileController {
                            let editUserProfileController = self.window?.visibleViewController as? EditUserProfileController
                            editUserProfileController?.dismiss(animated: true, completion: nil)
                            mainTabBarController.selectedIndex = 0
                        }
                    }
                    
                    // This is always performed --> Seguing from messages controller to chat log
                    if let messagesController = mainTabBarController.viewControllers?.first as? UINavigationController {
                        chatLogController.navigationController?.navigationBar.tintColor = UIColor.white
                        chatLogController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                        chatLogController.conversation = conversation
                        chatLogController.fromSearchController = false
                        messagesController.pushViewController(chatLogController, animated: true)
                    }
                }
                
            }, withCancel: nil)
            
        }
    }
    
    private func attemptRegisterForNotifications(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .authorized {
                // Push notifications already authorized, do nothing
                print ("push notifications authorized")
            } else if settings.authorizationStatus == .notDetermined {
                // User hasn't specified notification stauts
                UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
                    if let error = error {
                        print ("Failed to request authorization:", error)
                        return
                    }
                    
                    guard granted else {return}
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                })
            } else if settings.authorizationStatus == .denied {
                // User has denied notifications
                UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
                    
                    if let error = error {
                        print ("Failed to request authorization:", error)
                        return
                    }
                    
                    let alertController = UIAlertController(title: "Enable Push Notifications!", message: "Please enable push notifications in settings to receive chat messages", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    alertController.preferredAction = settingsAction
                    DispatchQueue.main.async {
                        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print ("we are in the background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print ("we have terminated")
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        imageCache.removeAll()
    }

}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
