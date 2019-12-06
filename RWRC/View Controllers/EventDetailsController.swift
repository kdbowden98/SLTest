
import UIKit

class EventDetailsController: UIViewController {

  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var descLabel: UILabel?
  @IBOutlet var locationLabel: UILabel?
  @IBOutlet var dateLabel: UILabel?
  @IBOutlet var timeLabel: UILabel?
  @IBOutlet var imageView: UIImageView?
  @IBOutlet var tierNumLabel: UILabel?
  @IBOutlet var campusLabel: UILabel?
  
  init(event: Event){
     self.event = event
     super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
   }
  
  var event: Event?
    override func viewDidLoad() {
      super.viewDidLoad()
      
      //load image if image path is specified
      if event!.imagePath != ""{
        var imagePath = "http://52.45.183.203/eventImages/"
        imagePath.append(event!.imagePath!)
        let filePath = URL(string: imagePath)
        imageView?.load(url: filePath!)
      } else{
        //otherwise, load logo as default
        imageView!.image = UIImage(named: "SLLogo")
      }

      //set details to labels
      titleLabel!.text = event?.title
      titleLabel!.textAlignment = .center
      descLabel!.text = event?.desc
      descLabel!.textAlignment = .center
      descLabel!.sizeToFit()
      locationLabel!.text = event?.location
      locationLabel!.sizeToFit()
      dateLabel!.text = event?.date
      timeLabel!.text = event?.time
      if event?.campus == ""{
        campusLabel!.text = "Statesboro"
      }else{
        campusLabel!.text = event?.campus
      }
      if event?.tierNumber == ""{
        tierNumLabel!.text = "All tiers"
      } else {
        tierNumLabel!.text = event?.tierNumber
      }
       
    }
  
}

  extension UIImageView{
    func load(url: URL){
      DispatchQueue.global().async{[weak self] in
        if let data = try? Data(contentsOf: url){
          if let image = UIImage(data: data){
            DispatchQueue.main.async {
              self?.image = image
            }
          }
        }
      }
    }
  }

