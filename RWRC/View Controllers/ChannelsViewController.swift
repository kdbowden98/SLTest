import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChannelsViewController: UITableViewController {
  
  private let toolbarLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()

  private let channelCellIdentifier = "channelCell"
  private var currentChannelAlertController: UIAlertController?
  
  private let db = Firestore.firestore()
  
  private var channelReference: CollectionReference {
    return db.collection("channels")
  }
  
  //false is sender, true is receiver
  private var receiver = false
  
  private var channels = [Channel]()
  private var channelListener: ListenerRegistration?
  private var userTo: String?
  
  private let currentUser: User
  
  deinit {
    channelListener?.remove()
  }
  
  init(currentUser: User) {
    self.currentUser = currentUser
    super.init(style: .grouped)
    
    title = "Messages"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: View Load
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("view load")
    
    clearsSelectionOnViewWillAppear = true
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
  
    //setting label to full name with user defaults updated on login
    let defaultValues = UserDefaults.standard
    if let fullName = defaultValues.string(forKey: "fullName"){
      toolbarLabel.text = fullName
    }
    setNavBarButtons()
    handleTierChannel()
    for var channel in channels {
      setChannelName(channel, completion: { check in 
        if self.receiver == true {
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        } else{
          let from = channel.from
          channel.name = channel.from
          channel.from = from
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      })
    }
    
    channelListener = channelReference.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }
  
  //set up navigation buttons
  func setNavBarButtons(){
    let button = UIButton(type: .custom)
    if #available(iOS 13.0, *) {
      button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
    } else {
      // Fallback on earlier versions
    }
    button.addTarget(self, action:  #selector(handleMenu), for: UIControl.Event.touchUpInside)
    let optionsButton = UIBarButtonItem(customView: button)
    let currWidth = optionsButton.customView?.widthAnchor.constraint(equalToConstant: 24)
    currWidth?.isActive = true
    let currHeight = optionsButton.customView?.heightAnchor.constraint(equalToConstant: 24)
    currHeight?.isActive = true
    
    
    let label = UIBarButtonItem(customView: toolbarLabel)
    let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    
    navigationItem.rightBarButtonItems = [optionsButton, add]
    navigationItem.leftBarButtonItem = label
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.isToolbarHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.isToolbarHidden = true
  }
  
  //MARK: Tier Handler
  
  func handleTierChannel(){
    let tier = UserDefaults.standard.string(forKey: "tierNumber")
    
    switch tier{
      case "1" :
        channelReference.getDocuments() { (QuerySnapshot, err)in
          if let err = err {
            print("tier one \(err)")
          } else{
            let tierOne = "Tier One"
            //create new channel of tier
            let channel = Channel(tier: tierOne)
            //check if tier channel is already in the channels array
            //channel will update when database is changed
            if !self.channels.contains(channel){
              let data = ["tier": tierOne]
              self.channels.append(channel)
              if self.channelReference.document("Tier One").documentID == ""{
                self.channelReference.document("Tier One").setData(data as [String : Any]) { error in
                  if let e = error{
                    print("error tier one \(e.localizedDescription)")
                  }
                }
              }else{
                DispatchQueue.main.async {
                  self.tableView.reloadData()
                }
              }
            }
          }
      }
      case "2" :
        channelReference.getDocuments() { (QuerySnapshot, err)in
            if let err = err {
              print("tier one \(err)")
            } else{
              let tierTwo = "Tier Two"
              //create new channel of tier
              let channel = Channel(tier: tierTwo)
              //check if tier channel is already in the channels array
              //channel will update when database is changed
              if !self.channels.contains(channel){
                let data = ["tier": tierTwo]
                self.channels.append(channel)
                if self.channelReference.document("Tier Two").documentID == ""{
                  self.channelReference.document("Tier Two").setData(data as [String : Any]) { error in
                    if let e = error{
                      print("error tier two \(e.localizedDescription)")
                    }
                  }
                } else{
                  DispatchQueue.main.async {
                    self.tableView.reloadData()
                  }
                }
              }
            }
        }
      case "3" :
        channelReference.getDocuments() { (QuerySnapshot, err) in
               if let err = err {
                 print("tier three \(err)")
               } else{
                 let tierThree = "Tier Three"
                 
                 //check for existing tier channel
                 let channel = Channel(tier: tierThree)
                 if !self.channels.contains(channel){
                  self.channels.append(channel)
                  let data = ["tier": tierThree]
                  if self.channelReference.document("Tier Three").documentID == ""{
                    self.channelReference.document("Tier Three").setData(data as [String : Any]) { error in
                      if let e = error{
                        print("error tier three \(e.localizedDescription)")
                      }
                    }
                  } else{
                    DispatchQueue.main.async {
                      self.tableView.reloadData()
                    }
                  }
                }
              }
            }
      default:
      return
    }
  }
  
  
  // MARK:  Actions
  //add conversation with single person, group messaging outside tiers not allowed as of right now
  @objc private func addButtonPressed() {
    let newMessagesController = NewMessagesController()
    newMessagesController.channelViewController = self
    let navController = UINavigationController(rootViewController: newMessagesController)
    present(navController, animated: true, completion: nil)
  }
  
  @objc private func textFieldDidChange(_ field: UITextField) {
    guard let ac = currentChannelAlertController else {
      return
    }
    
    ac.preferredAction?.isEnabled = field.hasText
  }
  
  func recipientCheck(_ channel: Channel, completion: @escaping (_ identifier: Bool) -> Void){
    let channelRef = db.collection("channels")
    var check = false
    let recipientChannels = channelRef.whereField("name", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
     //recipient test
    recipientChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error: \(err)")
      }else{
        for document in QuerySnapshot!.documents{
          //check if recipient is current user
          if channel.name == document.get("name") as? String{
            //return identifier recipient
            check = true
            completion(check)
          }
          else{
            completion(check)
          }
        }
      }
    }
  }
  
  func senderCheck(_ channel: Channel, completion: @escaping (_ identifier: Bool) -> Void){
    let channelRef = db.collection("channels")
    var check = false
    let senderChannels = channelRef.whereField("from", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
    
    senderChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error retrieving documents: \(err)")
      }else{
        //get recipient email
        for document in QuerySnapshot!.documents{
          //check if channel is from current recipient
          if channel.name == document.get("from") as? String{
            check = true
            completion(check)
          } else{
            completion(check)
          }
        }
      }
    }
  }
// func testChannel(user: Student, completion: @escaping (_ check: Bool) -> Void){
//    var checkOne = false
//    var checkTwo = false
//    checkChannel(user: user, completion: {check in
//      checkOne = check
//      self.doubleCheck(user: user, completion: {check in
//        checkTwo = check
//        completion(checkOne && checkTwo)
//      })
//    })
//  }
  //MARK: Set Channel Name
  
  private func setChannelName(_ channel: Channel, completion: @escaping (_ check: Bool) -> Void){
    var check = false
    recipientCheck(channel, completion: { identifier in
      self.receiver = true
      check = identifier
      self.senderCheck(channel, completion: {identifier in
        self.receiver = false
        check = identifier
        completion(check)
      })
    })
}
  
  //MARK: Menu functions
  let menuLauncher = MenuLauncher()
  
  @objc func handleMenu(){
    menuLauncher.channelController = self
    menuLauncher.handleMenu()
  }
  
  func showController(menu: Menu){
    switch menu.name {
    case "Progress":
      let progressViewController = ProgressController()
      progressViewController.navigationItem.title = menu.name
      progressViewController.view.backgroundColor = UIColor.white
      navigationController?.pushViewController(progressViewController, animated: true)
    case "Events":
      let eventsController = EventsController()
      eventsController.navigationItem.title = menu.name
      eventsController.view.backgroundColor = UIColor.white
      navigationController?.pushViewController(eventsController, animated: true)
    case "Messaging":
      let channelController = ChannelsViewController(currentUser: self.currentUser)
      channelController.navigationItem.title = menu.name
      channelController.view.backgroundColor = UIColor.white
      navigationController?.pushViewController(channelController, animated: true)
    case "Profile":
      let profileController = ProfileViewController()
      profileController.navigationItem.title = menu.name
      profileController.view.backgroundColor = UIColor.white
      navigationController?.pushViewController(profileController, animated: true)
    case "Cancel":
      menuLauncher.handleDismiss()
    default:
      menuLauncher.handleDismiss()
    }
  }
  
  // MARK: - Add Channel to Table
  
  private func addChannelToTable(_ channel: Channel) {
    guard !channels.contains(channel) else {
      return
    }
    let channelRef = db.collection("channels")
    let recipientChannels = channelRef.whereField("name", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
    let fromChannels = channelRef.whereField("from", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
    
    recipientChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error: \(err)")
      }else{
        for document in QuerySnapshot!.documents{
          //check if recipient is current user
          if channel.name == document.get("name") as? String{
            if !self.channels.contains(channel){
              self.channels.append(channel)
              self.channels.sort()

              guard let index = self.channels.index(of: channel) else {
                  return
              }
              self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
              
              DispatchQueue.main.async {
                self.tableView.reloadData()
              }
            }
          }
        }
      }
    }
    fromChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error retrieving documents: \(err)")
      }else{
        //get recipient email
        for document in QuerySnapshot!.documents{
          //check if channel is from current recipient
          if channel.from == document.get("from") as? String{
            if !self.channels.contains(channel){
              self.channels.append(channel)
              self.channels.sort()

              guard let index = self.channels.index(of: channel) else {
                  return
              }
              self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                
              DispatchQueue.main.async {
                self.tableView.reloadData()
              }
            }
          }
        }
      }
    }
  }
  
  //MARK: Update Channel in Table
  
  private func updateChannelInTable(_ channel: Channel) {
    print("inside update")
    guard channels.index(of: channel) != nil else {
      return
    }
    let channelRef = db.collection("channels")
    let recipientChannels = channelRef.whereField("name", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
    let fromChannels = channelRef.whereField("from", isEqualTo: UserDefaults.standard.string(forKey: "fullName") as Any)
  
    recipientChannels.getDocuments(){(QuerySnapshot, err) in
      if let err = err{
        print("error: \(err)")
      }else{
        for document in QuerySnapshot!.documents{
          //check if recipient is current user
          if channel.name == document.get("name") as? String{
           if !self.channels.contains(channel){
              self.channels.append(channel)
              self.channels.sort()

              guard let index = self.channels.index(of: channel) else {
                  return
              }
              self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
              DispatchQueue.main.async {
                self.tableView.reloadData()
              }
            }
          }
        }
      }
    }
    fromChannels.getDocuments(){(QuerySnapshot, err) in
        if let err = err{
          print("error retrieving documents: \(err)")
        }else{
          //get recipient email
          for document in QuerySnapshot!.documents{
            //check if channel is from current recipient
            if channel.from == document.get("from") as? String{
             if !self.channels.contains(channel){
                self.channels.append(channel)
                self.channels.sort()

                guard let index = self.channels.index(of: channel) else {
                    return
                }
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
              
                DispatchQueue.main.async {
                  self.tableView.reloadData()
                }
              }
            }
          }
        }
      }
  }
  
  private func removeChannelFromTable(_ channel: Channel) {
    guard let index = channels.index(of: channel) else {
      return
    }
    
    channels.remove(at: index)
    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard let channel = Channel(document: change.document) else {
      return
    }
    
    switch change.type {
    case .added:
      addChannelToTable(channel)
      
    case .modified:
      updateChannelInTable(channel)
      
    case .removed:
      removeChannelFromTable(channel)
    }
  }
  
}

// MARK: - TableViewDelegate

extension ChannelsViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return channels.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
    print("return cell")
    
    cell.textLabel?.text = self.channels[indexPath.row].name
    cell.accessoryType = .disclosureIndicator
     
     return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let channel = channels[indexPath.row]
    userTo = ""
    let vc = ChatViewController(user: currentUser, channel: channel, userTo: userTo!)
    navigationController?.pushViewController(vc, animated: true)
  }
}
