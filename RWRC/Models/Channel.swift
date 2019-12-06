import FirebaseFirestore
import Firebase
import MessageKit

struct Channel {
  
  let id: String?
  var name: String
  var from: String
  
  init(name: String, from: String) {
    id = nil
    self.name = name
    self.from = from
  }
  
  //for creation of tier channel
  init(tier: String){
    id = tier
    self.name = tier
    self.from = ""
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    guard let name = data["name"] as? String else {
      return nil
    }
    guard let from = data["from"] as? String else{
      return nil
    }
    
    id = document.documentID
    self.name = name
    self.from = from
  }
  
}

extension Channel: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "name" : name,
      "from" : from ,
    ]
    
    if let id = id {
      rep["id"] = id
    }
    
    return rep
  }
  
}

extension Channel: Comparable {
  
  static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }

}
