import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchConversationController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var messagesController: MessagesController?
    
    let cellId = "cellId"
    
    var conversations = [Conversation]()
    var filteredConversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2392, green: 0.2588, blue: 0.3961, alpha: 1)

        view.layer.configureGradientBackground(UIColor(red: 0, green: 0.7882, blue: 0.4118, alpha: 1).cgColor, UIColor(red: 0.0921, green: 0.9047, blue: 1, alpha: 1).cgColor)
        collectionView?.backgroundColor = .clear 
        
        navigationItem.titleView = searchBar
                
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false 
        
        collectionView?.register(ConvoSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        fetchConvos()
        
    }
    
    
    func fetchConvos() {
        
        let ref = Database.database().reference().child("conversations")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                                
                guard let convoDictionary = value as? [String:Any] else {return}
                let conversation = Conversation(dictionary: convoDictionary as [String : AnyObject])
                Database.database().reference().child("conversation_users").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    conversation.numberOfMembers = Int(snapshot.childrenCount)
                    
                    self.conversations.append(conversation)
                    
                    self.conversations.sort { (c1, c2) -> Bool in
                        return (c1.lastMessageTime?.intValue)! > (c2.lastMessageTime?.intValue)!
                    }
                    
                    self.filteredConversations = self.conversations
                    
                    self.collectionView?.reloadData()
                })
                
            })
            
        }) { (error) in
            print ("Couldn't fetch list of convos")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredConversations = conversations
        } else {
            self.filteredConversations = self.conversations.filter({ (conversation) -> Bool in
                return (conversation.conversationName?.lowercased().contains(searchText.lowercased()))!
            })
        }
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredConversations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ConvoSearchCell
        cell.conversation = filteredConversations[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            let convo = filteredConversations[indexPath.item]
            
            guard let convoId = convo.conversationId, let conversationName = convo.conversationName else {return}
            
            if bannedConversations.contains(convoId) {
                let alertController = UIAlertController(title: "You have been banned from \(conversationName)", message: "Enough members voted to ban you. Please conduct yourself accordingly next time.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "\u{1F62D}\u{1F62D}\u{1F62D}\u{1F62D}", style: .default, handler: { (_) in
                    alertController.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                searchBar.isHidden = true
                searchBar.resignFirstResponder()
                
                showChatController(convo: convo, convoId: convoId)
            }
            
        
    
    }
    
    func showChatController(convo: Conversation, convoId: String) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.conversation = convo
        chatLogController.fromSearchController = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 72)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search for Chats"
        sb.barTintColor = UIColor.gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(r: 230, g: 230, b: 230)
        sb.delegate = self
        return sb
    }()
    
}

