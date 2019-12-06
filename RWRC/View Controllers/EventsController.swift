import UIKit
import Alamofire

class EventsController: UITableViewController {
  
//  struct headerStrcut{
//    var label: String!
//  }
  
    let EVENTS_URL = "http://52.45.183.203/signuptest/v1/fetchEvents.php"
    let cellID = "CellId"
    var events = [Event]()
    var currEvents = [Event]()
  
    var twoDimArr = [
      ExpandableEvent(isExpanded: true, events: [])
    ]
    
  
    var tierNumber = 1
        
    override func viewDidLoad() {
      super.viewDidLoad()
      
      twoDimArr.removeAll()
      
      tierNumber = UserDefaults.standard.integer(forKey: "tierNumber")
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
      
      fetchEvents()
    }

//MARK: Table Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
      return twoDimArr.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimArr[section].isExpanded{
          return 0
        }
        return twoDimArr[section].events.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        //set title of event
        let event = twoDimArr[indexPath.section].events[indexPath.row].title
        cell.textLabel?.text = event

        return cell
        
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      dismiss(animated: true){
        //pass event details of selected row to details view
        let event = self.twoDimArr[indexPath.section].events[indexPath.row]
        let vc = EventDetailsController(event: event)
        self.navigationController?.pushViewController(vc, animated: true)
        print("dismiss complete")
    }
  }
  
  //MARK: Database
  
  func fetchEvents(){
    var event = Event(title: "", desc: "", location: "", date: "", time: "", imagePath:  "", eventMonth: "", tierNumber: "", campus: "")

    let parameters: Parameters=[
        "tierNumber": tierNumber
      ]
    
      Alamofire.request(EVENTS_URL, method: .post, parameters: parameters).responseJSON(){
        response in
        print(response)
        
        if let results = response.result.value as? [[String: Any]]{
          for result in results{
            
            let date = (result as AnyObject).value(forKey: "date") as? String
            let desc = (result as AnyObject).value(forKey: "description") as? String
            let location = (result as AnyObject).value(forKey: "location") as? String
            let path = (result as AnyObject).value(forKey: "pathName") as? String
            let time = (result as AnyObject).value(forKey: "time") as? String
            let title = (result as AnyObject).value(forKey: "title") as? String
            let tierNum = (result as AnyObject).value(forKey: "tierNumber") as? String
            let campus = (result as AnyObject).value(forKey: "campus") as? String
            var eventMonth = ""
            var dateValue = 0
            var year = ""
            
            //set event month for placement in sections
            if date != nil{
              let index1 = date!.index(date!.startIndex, offsetBy: 5)
              let index2 = date!.index(date!.startIndex, offsetBy: 6)
              
              let year1 = date?.startIndex
              let year2 = date!.index(date!.startIndex, offsetBy: 1)
              let year3 = date!.index(date!.startIndex, offsetBy: 2)
              let year4 = date!.index(date!.startIndex, offsetBy: 3)
              year.append(date![year1!])
              year.append(date![year2])
              year.append(date![year3])
              year.append(date![year4])
          
              eventMonth.append(date![index1])
              eventMonth.append(date![index2])
              switch eventMonth{
                case "01": eventMonth = "January"
                  dateValue = 1
                case "02": eventMonth = "February"
                  dateValue = 2
                case "03": eventMonth = "March"
                  dateValue = 3
                case "04": eventMonth = "April"
                  dateValue = 4
                case "05": eventMonth = "May"
                  dateValue = 5
                case "06": eventMonth = "June"
                  dateValue = 6
                case "07": eventMonth = "July"
                  dateValue = 7
                case "08": eventMonth = "August"
                  dateValue = 8
                case "09": eventMonth = "September"
                  dateValue = 9
                case "10": eventMonth = "October"
                  dateValue = 10
                case "11": eventMonth = "November"
                  dateValue = 11
                case "12": eventMonth = "December"
                  dateValue = 12
              default: eventMonth = ""
              }
            }
            //get current month
            let now = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "LLLL"
            let currentMonth = dateFormat.string(from: now)
            dateFormat.dateFormat = "yyyy"
            let currentYear = dateFormat.string(from: now)
            dateFormat.dateFormat = "MM"
            let currDateValue = Int(dateFormat.string(from: now))
            let userTier = String(self.tierNumber)
            
            
            //create event object with event information where image path exists
            if path != nil{
              
              //if event is in the future
              if year == currentYear {
                if dateValue >= currDateValue!{
                  if (tierNum?.contains(userTier))! {
                  //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month, add to future events array
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  } else if tierNum == "" {
                    //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  }
                }
              } else if year > currentYear{
                if (tierNum?.contains(userTier))! {
                  //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month, add to future events array
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  } else if tierNum == "" {
                    //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: path!, eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  }
              }
              //if image path is nil
            } else {
              if year == currentYear {
                if dateValue >= currDateValue!{
                  if (tierNum?.contains(userTier))! {
                  //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month, add to future events array
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  } else if tierNum == "" {
                    //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  }
                }
              } else if year > currentYear{
                if (tierNum?.contains(userTier))! {
                  //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month, add to future events array
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  } else if tierNum == "" {
                    //if event is in current month, add to event array and display in first section
                    if eventMonth == currentMonth{
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.currEvents.append(event)
                    }else{
                      //if eventMonth is not current Month
                      event = Event(title: title!, desc: desc!, location: location!, date: date!, time: time!, imagePath: "", eventMonth: eventMonth, tierNumber: tierNum!, campus: campus!)
                      self.events.append(event)
                    }
                  }
              }
            }
          }
            
          if !self.currEvents.isEmpty{
            //append currentMonth events into current month section, if there are current month events
            if self.currEvents[0].title != "" {
              self.twoDimArr.append(ExpandableEvent(isExpanded: true, events: self.currEvents))
            }
          }
            //set displayed two dim arr to contain all future events
            self.twoDimArr.append(ExpandableEvent(isExpanded: true, events: self.events))
          
            //reload table
            DispatchQueue.main.async {
               self.tableView.reloadData()
            }
        }
    }
  }
  
  
  //  MARK: Header Functions
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let button = UIButton(type: .system)
    
    if twoDimArr.count == 1{
      button.setTitle("Future Events", for: .normal)
    } else{
      if section == 0{
        button.setTitle("This Month's Events", for: .normal)
      } else{
        button.setTitle("Future Events", for: .normal)
      }
    }
    button.backgroundColor = .header
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
  
    button.tag = section

    return button
  }
  
  @objc func handleExpandClose(button: UIButton){
    let section = button.tag
  
    //close section
    var indexPaths = [IndexPath]()
    for row in twoDimArr[section].events.indices{
      let indexPath = IndexPath(row: row, section: section)
      indexPaths.append(indexPath)
    }
  
    let isExpanded = twoDimArr[section].isExpanded
    twoDimArr[section].isExpanded = !isExpanded
    
    if section == 0{
      button.setTitle(isExpanded ? "This Month's Events" : "This Month's Events", for: .normal)
    } else{
      button.setTitle(isExpanded ? "Future Events" : "Future Events", for: .normal)
    }
  
    if isExpanded{
      tableView.deleteRows(at: indexPaths, with: .fade)
    } else {
      tableView.insertRows(at: indexPaths, with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  
    
}
