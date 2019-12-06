import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class NewMessagesController: UITableViewController {
  let cellId = "cellId"
  private let db = Firestore.firestore()
  
  private var channelReference: CollectionReference {
    return db.collection("channels")
  }
  private let currentUser: User = Auth.auth().currentUser!
  
  var users = [Student]()
  
  override func viewDidLoad() {
      super.viewDidLoad()

      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
             
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
            
      fetchUser()
  }
        
  //MARK: Fetch users
  func fetchUser(){
      let db = Firestore.firestore()
  
      //query firestore for all user information
      db.collection("user-info").getDocuments(){(QuerySnapshot, err) in
          if let err = err{
              print("error retrieving documents: \(err)")
          }else{
               //parse individual user information and assign to a user object
              for document in QuerySnapshot!.documents{
                let user = Student()
                    
                user.fullName  = document.get("name") as? String
                user.tier = document.get("tier") as? Int
                user.email = document.documentID
                
                if user.fullName != AppSettings.displayName {
                  //if current doc name is not current user, don't add to tableview
                  self.users.append(user)
                }
                DispatchQueue.main.async {
                  self.tableView.reloadData()
                  }
              }
          }
      }
  }
      
  @objc func handleCancel(){
      dismiss(animated: true, completion: nil)
  }
    // MARK: - Table view functions
  
  override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return users.count
  }
    
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
          
        print(" --- section = \(indexPath.section), row = \(indexPath.row)")
          
          let user = users[indexPath.row]
          cell.textLabel?.text = user.fullName
            
          return cell
  }
  
  var channelViewController: ChannelsViewController?
  
  func doubleCheck(user: Student, completion: @escaping (_ check: Bool) -> Void){
    let db = Firestore.firestore()
    
    let user = user
    let channelRef = db.collection("channels")
 
    let doubleCheckChannel = channelRef.whereField("name", isEqualTo: AppSettings.displayName).whereField("from", isEqualTo: user.fullName!)
      
    doubleCheckChannel.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error : \(err)")
      }else{
        if QuerySnapshot!.isEmpty{
          let check = true
          completion(check)
        }else{
          let check = false
          completion(check)
        }
      }
    }
  }
  
  func checkChannel(user: Student, completion: @escaping  (_ check: Bool) -> Void){
    let db = Firestore.firestore()
    
    let user = user
    let channelRef = db.collection("channels")
    let userChannels =  channelRef.whereField("name", isEqualTo: user.fullName!).whereField("from", isEqualTo: AppSettings.displayName)
      
    userChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error retrieving documents: \(err)")
      }else{
        //check if channel exists between current user and chosen user
        if QuerySnapshot!.isEmpty {
          let check = true
          completion(check)
        }else{
          let check = false
          completion(check)
        }
      }
    }
  }
  
  func testChannel(user: Student, completion: @escaping (_ check: Bool) -> Void){
    var checkOne = false
    var checkTwo = false
    checkChannel(user: user, completion: {check in
      checkOne = check
      self.doubleCheck(user: user, completion: {check in
        checkTwo = check
        completion(checkOne && checkTwo)
      })
    })
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    testChannel(user: self.users[indexPath.row], completion: {check in
        if check == true {
          let user = self.users[indexPath.row]
          let from = AppSettings.displayName
          self.createChannel(user: user, userTo: self.users[indexPath.row].email!)
          let channel = Channel(name: user.fullName!, from: from!)
          let alert = UIAlertController(title: "Channel was created!", message: "The channel between you and the chosen user was created.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.dismiss(animated: true)
          }))
          self.present(alert, animated: true)
        } else{
          let alert = UIAlertController(title: "Channel already exists!", message: "The channel between you and the chosen user already exists.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.dismiss(animated: true)
          }))
          self.present(alert, animated: true)
        }
    })
  }
  
  private func createChannel(user: Student, userTo: String) {
    let user = user.fullName
    let from = AppSettings.displayName
     
    let channel = Channel(name: user!, from: from!)
    channelReference.addDocument(data: channel.representation) { error in
       if let e = error {
         print("Error saving channel: \(e.localizedDescription)")
       }
     }
   }
}
