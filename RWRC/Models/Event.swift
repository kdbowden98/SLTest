import UIKit

class Event: NSObject {
  var title: String?
  var desc: String?
  var campus: String = "Statesboro"
  var location: String?
  var date: String?
  var time: String?
  var imagePath: String?
  var eventMonth: String?
  var tierNumber: String?
  
  init(title: String, desc: String, location: String, date: String, time: String, imagePath: String, eventMonth: String, tierNumber: String, campus: String) {
    self.title = title
    self.desc = desc
    self.location = location
    self.date = date
    self.time = time
    self.imagePath = imagePath
    self.eventMonth = eventMonth
    self.tierNumber = tierNumber
    self.campus = campus
   }
   
}
