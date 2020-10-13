import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    var notificationDescription: String?
    var notificationTitle: String?
    var notificationDate: Double?
    
    weak var calendarTransitionDelegate: PresentCalendarAlertProtocol!
    
    var notification: Notification? {
        didSet {
            guard let description = notification?.notificationDescription else {return}
            descriptionLabel.text = description
            notificationDescription = description
            
            guard let date = notification?.notificationDate else {return}
            self.notificationDate = date.doubleValue

            let second = date.doubleValue
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy HH:mm"
            let gmtDate = dateFormatter.string(from: Date(timeIntervalSince1970: second))
            let localDate = UTCToLocal(date: gmtDate)
            
            let day = getDayOfWeek(today: localDate)
            self.timeLabel.text = "\(day), \(localDate)"

            guard let title = notification?.notificationTitle else {return}
            notificationTitle = title
        }
    }
    
    var localDate: Date?
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        localDate = dt
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        
        return dateFormatter.string(from: dt!)
    }
    
    func getDayOfWeek(today:String)->String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        let todayDate = formatter.date(from: today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(NSCalendar.Unit.weekday, from: todayDate)
        let weekDay = myComponents.weekday
        var weekDayString: String?
        if weekDay == 1 {
            weekDayString = "Sun"
        } else if weekDay == 2 {
            weekDayString = "Mon"
        } else if weekDay == 3 {
            weekDayString = "Tues"
        } else if weekDay == 4 {
            weekDayString = "Wed"
        } else if weekDay == 5 {
            weekDayString = "Thu"
        } else if weekDay == 6 {
            weekDayString = "Fri"
        } else if weekDay == 7 {
            weekDayString = "Sat"
        }
        return weekDayString!
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        
        selectionStyle = .none
        
        addSubview(addToCalendarButton)
        addToCalendarButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: (10/375) * UIScreen.main.bounds.width, width: 40, height: 40)
        addToCalendarButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(descriptionLabel)
        descriptionLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: addToCalendarButton.leftAnchor, paddingTop: 2, paddingLeft: 5, paddingBottom: 0, paddingRight: 15, width: 0, height: 35)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: descriptionLabel.bottomAnchor, left: descriptionLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 30)
        
        addSubview(separatorView)
        separatorView.anchor(top: bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    lazy var addToCalendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "add_to_calendar"), for: .normal)
        button.clipsToBounds = true
        button.tintColor = UIColor(red: 0.4980, green: 0, blue: 0.8902, alpha: 1)
        
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addToCalendarButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func addToCalendarButtonTapped() {
        print ("calendar button tapped")
        
        if let localDate = self.localDate {
            if let title = notificationTitle, let description = notificationDescription {
                calendarTransitionDelegate.presentCalendarAlert(title: title, description: description, date: localDate)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
