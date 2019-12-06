import UIKit
import Alamofire

class ProgressController: UITableViewController {
        
    let PROGRESS_URL = "http://52.45.183.203/signuptest/v1/fetchProgress.php"
    let cellID = "CellId"
  
    //tier 1
    var coachingProgram: String?
    var lead1000: String?
    var t1Showcase: String?
    //tier 2
    var serviceReflection: String?
    var legacyProposal: String?
    var lead2000: String?
    var t2Showcase: String?
    //tier 3
    var legacyProject: String?
    var lead3000: String?
    var portfolio: String?
    var t3Showcase: String?
  
    var email = ""
    var tierNumber = ""

    var twoDimArr = [
      ExpandableStep(isExpanded: true, steps: ["LEAD 1000", "Coaching Program", "Southern Leaders Showcase"], completed: ["false", "false", "false"]),
      ExpandableStep(isExpanded: true, steps:  ["LEAD 2000", "Five Hours of Service Reflection", "Legacy Project Proposal", "Southern Leaders Showcase"], completed: ["false", "false", "false", "false"]),
      ExpandableStep(isExpanded: true, steps: ["LEAD 3000", "Legacy Project Completion", "Leadership Portfolio", "Southern Leaders Showcase"], completed: ["false", "false", "false", "false"])
    ]
  
  
  //MARK: View loader
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.register(ProgressCell.self, forCellReuseIdentifier: cellID)
      
      email = UserDefaults.standard.string(forKey: "email")!
      tierNumber = UserDefaults.standard.string(forKey: "tierNumber")!
      print(tierNumber)
      
      setCompleted()
    }
  
  func databaseCall(completionHandler: @escaping  (_ resonse: DataResponse<Any>) -> Void){
    let parameters: Parameters=[
        "email": email,
        "tierNumber": tierNumber
      ]
    
      Alamofire.request(PROGRESS_URL, method: .post, parameters: parameters).responseJSON(){
        response in
        print(response)
        completionHandler(response)
    }
  }
  
  //MARK: Set completed
    func setCompleted(){
        databaseCall(completionHandler: {response in
          if let result = response.result.value {
            //tier 1\

            self.coachingProgram = ((result as AnyObject).value(forKey: "CoachingProgram") as? String)!
            self.lead1000 = ((result as AnyObject).value(forKey: "LEAD1000") as? String)!
            self.t1Showcase = ((result as AnyObject).value(forKey: "Showcase1") as? String)!
           
            //tier 2
            self.serviceReflection = ((result as AnyObject).value(forKey: "FiveHourServiceReflection") as? String)!
            self.lead2000 = ((result as AnyObject).value(forKey: "LEAD2000") as? String)!
            self.legacyProposal = ((result as AnyObject).value(forKey: "LegacyProjectProposal") as? String)!
            self.t2Showcase = ((result as AnyObject).value(forKey: "Showcase2")
                as? String)!
                
            //tier 3
            self.legacyProject = ((result as AnyObject).value(forKey: "LeadershipLegacyProject") as? String)!
            self.lead3000 = ((result as AnyObject).value(forKey: "LEAD3000") as? String)!
            self.portfolio = ((result as AnyObject).value(forKey: "LeadershipPortfolio") as? String)!
            self.t3Showcase = ((result as AnyObject).value(forKey: "Showcase3") as? String)!
                 
            if self.coachingProgram == "1" {
              self.twoDimArr[0].completed[1] = "In Progress"
            }else if self.coachingProgram == "2"{
              self.twoDimArr[0].completed[1] = "Completed"
            }
                   
            if self.lead1000 == "1" {
              self.twoDimArr[0].completed[0] = "In Progress"
            }else if self.lead1000 == "2"{
              self.twoDimArr[0].completed[0] = "Completed"
            }
                   
            if self.t1Showcase == "1" {
              self.twoDimArr[0].completed[2] = "In Progress"
            }else if self.t1Showcase == "2"{
              self.twoDimArr[0].completed[2] = "Completed"
            }
            //tier 2
            if self.serviceReflection == "1" {
              self.twoDimArr[1].completed[1] = "In Progress"
            }else if self.serviceReflection == "2"{
              self.twoDimArr[1].completed[1] = "Completed"
            }
                  
            if self.legacyProposal == "1" {
              self.twoDimArr[1].completed[2] = "In Progress"
            }else if self.legacyProposal == "2"{
              self.twoDimArr[1].completed[2] = "Completed"
            }
                   
            if self.lead2000 == "1" {
              self.twoDimArr[1].completed[0] = "In Progress"
            }else if self.lead2000 == "2" {
              self.twoDimArr[1].completed[0] = "Completed"
            }
                   
            if self.t2Showcase == "1" {
              self.twoDimArr[1].completed[3] = "In Progress"
            }else if self.t2Showcase == "2"{
              self.twoDimArr[1].completed[3] = "Completed"
            }
            //tier 3
            if self.legacyProject == "1" {
              self.twoDimArr[2].completed[1] = "In Progress"
            }else if self.legacyProject == "2"{
              self.twoDimArr[2].completed[1] = "Completed"
            }
                   
            if self.lead3000 == "1" {
              self.twoDimArr[2].completed[0] = "In Progress"
            }else if self.lead3000 == "2"{
              self.twoDimArr[2].completed[0] = "Completed"
            }
                   
            if self.portfolio == "1" {
              self.twoDimArr[2].completed[2] = "In Progress"
            }else if self.portfolio == "2"{
              self.twoDimArr[2].completed[2] = "Completed"
            }
                   
            if self.t3Showcase == "1" {
              self.twoDimArr[2].completed[3] = "In Progress"
            }else if self.t3Showcase == "2"{
              self.twoDimArr[2].completed[3] = "Completed"
            }
                 
            if self.tierNumber == "2"{
              print("tier 2")
              self.twoDimArr[0].completed[0] = "Completed"
              self.twoDimArr[0].completed[1] = "Completed"
              self.twoDimArr[0].completed[2] = "Completed"
            }
            if self.tierNumber == "3"{
              print("tier 3")
              self.twoDimArr[0].completed[0] = "Completed"
              self.twoDimArr[0].completed[1] = "Completed"
              self.twoDimArr[0].completed[2] = "Completed"
              self.twoDimArr[1].completed[0] = "Completed"
              self.twoDimArr[1].completed[1] = "Completed"
              self.twoDimArr[1].completed[2] = "Completed"
              self.twoDimArr[1].completed[3] = "Completed"
            }
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
          }
        })
  }

  
  //MARK: Table Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
      return twoDimArr.count
    }

  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if !twoDimArr[section].isExpanded{
        return 0
      }
      return twoDimArr[section].steps.count
    }
  
  
  //MARK: Header functions
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let button = UIButton(type: .system)
      if section == 0{
        button.setTitle("Tier One", for: .normal)
      } else if section == 1{
        button.setTitle("Tier Two", for: .normal)
      } else{
        button.setTitle("Tier Three", for: .normal)
      }
      
      button.backgroundColor = .header
      button.setTitleColor(.black, for: .normal)
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    
      button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
    
      button.tag = section
    
      return button
    }
  
    @objc func handleExpandClose(button: UIButton){
      let section = button.tag
    
      //close section
      var indexPaths = [IndexPath]()
      for row in twoDimArr[section].steps.indices{
        let indexPath = IndexPath(row: row, section: section)
        indexPaths.append(indexPath)
      }
    
      let isExpanded = twoDimArr[section].isExpanded
      twoDimArr[section].isExpanded = !isExpanded
    
//      button.setTitle(isExpanded ? "Open" : "Collapse", for: .normal)
    
      if isExpanded{
        tableView.deleteRows(at: indexPaths, with: .fade)
      } else {
        tableView.insertRows(at: indexPaths, with: .fade)
      }
    
    }
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 36
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProgressCell
      
      if twoDimArr[indexPath.section].completed[indexPath.row] == "Completed"{
        cell.completedLabel.text = "Completed!"
        cell.completedLabel.textColor = .green
      } else if twoDimArr[indexPath.section].completed[indexPath.row] == "In Progress"{
        cell.completedLabel.text = "Under Review"
        cell.completedLabel.textColor = .yellow
      }else{
        cell.completedLabel.text = "Not Completed"
        cell.completedLabel.textColor = .red
      }
    
      let step = twoDimArr[indexPath.section].steps[indexPath.row]
      cell.textLabel?.text = step

      return cell
    }
  
  
}
