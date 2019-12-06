import FirebaseFirestore
import Firebase
import MessageKit

struct Tier {
  let id: String?
  let users: [String]?
  
  init(users: [String]){
    id = nil
    self.users = users
  }
  
  init?(document: QueryDocumentSnapshot){
    let data = document.data()
    
    guard let users = data["users"] as? [String] else{
      return nil
    }
    
    id = document.documentID
    self.users = users
  }
  
}

extension Tier: DatabaseRepresentation {
  var representation: [String : Any] {
    var rep: [String: Any] = [
      "users" : users
    ]
  
    if let id = id{
      rep["id"] = id
    }
    return rep
  }
}
