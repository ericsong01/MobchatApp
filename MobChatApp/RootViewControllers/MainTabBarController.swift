import UIKit
import Firebase
import FirebaseAuth

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser?.uid == nil {
            // User isn't signed in, show login controller
            DispatchQueue.main.async {
                print ("user isn't signed in")
                let openingVC = OpeningScreenViewController()
                let navController = UINavigationController(rootViewController: openingVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
            // User is signed in
            setupViewControllers()
        
    }
    
    func setupViewControllers() {
        print ("user is signed in")
        let messagesController = templateNavController(unselectedImage: #imageLiteral(resourceName: "chat_icon"), selectedImage: #imageLiteral(resourceName: "chat_icon").withRenderingMode(.alwaysOriginal), rootViewController: MessagesController())
        let zrofileController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_icon"), selectedImage: #imageLiteral(resourceName: "profile_icon").withRenderingMode(.alwaysOriginal), rootViewController: UserProfileController())
        let searchController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_icon"), selectedImage: #imageLiteral(resourceName: "search_icon").withRenderingMode(.alwaysOriginal), rootViewController: SearchConversationController(collectionViewLayout: UICollectionViewFlowLayout()))
                
        tabBar.barTintColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)
        tabBar.tintColor = .black
        viewControllers = [messagesController, searchController, zrofileController]
        
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    // Refactor view controller code
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
        
    }

    
}

