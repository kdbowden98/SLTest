import UIKit
import FirebaseFirestore
import FirebaseAuth
import Alamofire

class ProfileViewController: UIViewController {

  private let currentUser = Auth.auth().currentUser
  private let STUDENT_URL = "http://52.45.183.203/signuptest/v1/fetchStudent.php"
  
  @IBOutlet var logoutButton: UIButton!
  @IBOutlet var nameText: UILabel!
  @IBOutlet var tierNumberText: UILabel!
  @IBOutlet var buttonBacking: UIView!
  @IBOutlet var advisorText: UILabel!
  @IBOutlet var majorText: UILabel!
  @IBOutlet var expectedGradText: UILabel!
  @IBOutlet var hometownText: UILabel!
  @IBOutlet var campusText: UILabel!
  
  private let db = Firestore.firestore()
  
  var tierNumber = 1
  var email = ""
    
  private var userReference: CollectionReference {
    return db.collection("user-info")
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
      nameText.sizeToFit()
      nameText.textAlignment = .center
    
      buttonBacking.layer.cornerRadius = 20
      email = UserDefaults.standard.string(forKey: "email")!
      tierNumber = UserDefaults.standard.integer(forKey: "tierNumber")
    
      fetchStudent()

      nameText.text = AppSettings.displayName
      tierNumberText.text = String(tierNumber)

    }
  
  @IBAction func logoutButtonClicked() {
    signOut()
  }
  
  func fetchStudent(){
    
     let parameters: Parameters=[
      "email":email
      ]
    Alamofire.request(STUDENT_URL, method: .post, parameters: parameters).responseJSON(){
    response in
      print(response)
      
      if let result = response.result.value{
        
        self.advisorText.text = (result as AnyObject).value(forKey: "advisor") as? String
        self.campusText.text = (result as AnyObject).value(forKey: "campus") as? String
        self.expectedGradText.text = (result as AnyObject).value(forKey: "expectedGrad") as? String
        self.majorText.text = (result as AnyObject).value(forKey: "major") as? String
        self.hometownText.text = (result as AnyObject).value(forKey: "hometown") as? String
      }
    }
  }
  
  
  @objc private func signOut() {
     let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
     ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
     ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
       do {
         try Auth.auth().signOut()
       } catch {
         print("Error signing out: \(error.localizedDescription)")
       }
     }))
     present(ac, animated: true, completion: nil)
   }

}
