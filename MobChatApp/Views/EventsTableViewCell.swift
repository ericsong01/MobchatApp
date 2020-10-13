
import UIKit

class EventsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(expandButton)
        expandButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 30, height: 30)
        expandButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(eventTitleLabel)
        eventTitleLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        eventTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eventTitleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 230/375).isActive = true
        
        addSubview(eventTimeLabel)
        eventTimeLabel.anchor(top: nil, left: eventTitleLabel.rightAnchor, bottom: nil, right: expandButton.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 15, width: 0, height: 40)
        eventTimeLabel.centerYAnchor.constraint(equalTo: eventTitleLabel.centerYAnchor).isActive = true
        
        if UIScreen.main.bounds.height < 667 {
            eventTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            eventTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }
    }
    
    weak var expandCellDelegate: ExpandCellProtocol!
    
    let eventTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    let eventTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "expand_arrow_button"), for: .normal)
        button.clipsToBounds = true
        button.tintColor = UIColor(red: 0.4980, green: 0, blue: 0.8902, alpha: 1)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    @objc func expandTapped() {
        
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return
        }
        
        guard let indexPath = superView.indexPath(for: self) else {return}
        
        expandCellDelegate.expandCell(for: indexPath)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

