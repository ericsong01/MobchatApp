import UIKit

class HighlightsLogView: UIView {
    
    weak var refreshDelegate: RefreshChatLogProtocol!
    
    let tableView: HighlightsLogTableView = {
        let tableView = HighlightsLogTableView()
        return tableView
    }()
    
    let blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return blurView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        tableView.showsVerticalScrollIndicator = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.purple.cgColor
        
    }
    
    @objc func handleRefresh() {
        refreshDelegate.refreshChatLog()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HighlightsLogTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .grouped)
        backgroundColor = .clear
        separatorStyle = .none
        allowsSelection = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HighlightLogTableViewCell: UITableViewCell {
    
    let logLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "highlightLogCellId")
        
        backgroundColor = .clear 
        
        addSubview(logLabel)
        logLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TableSectionHeader: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.text = "Chat Logs"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    let recentLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "Most Recent"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: "tableHeader")
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.bounds.width, height: 20)
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        
        addSubview(recentLabel)
        recentLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        recentLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 3, paddingLeft: 0, paddingBottom: 3, paddingRight: 0, width: self.bounds.width, height: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
