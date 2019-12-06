import UIKit
import FirebaseAuth
import Alamofire
import Firebase
import FirebaseFirestore

class LoginViewController: UIViewController {
  let URL_USER_LOGIN = "http://52.45.183.203/signuptest/v1/login.php"
  
  private let db = Firestore.firestore()
   
   private var channelReference: CollectionReference {
     return db.collection("channels")
   }
  
  let defaultValues = UserDefaults.standard
  
  @IBOutlet var fieldBackingView: UIView!
  @IBOutlet var displayEmailField: UITextField!
  @IBOutlet var displayPasswordField: UITextField!
  @IBOutlet var actionButtonBackingView: UIView!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!
  @IBOutlet var actionButton: UIButton!
  @IBOutlet var passwordView: UISegmentedControl!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fieldBackingView.smoothRoundCorners(to: 8)
    actionButtonBackingView.smoothRoundCorners(to: actionButtonBackingView.bounds.height / 2)
    
    displayEmailField.tintColor = .primary
    displayEmailField.addTarget(
      self,
      action: #selector(textFieldDidReturn),
      for: .primaryActionTriggered
    )
    
    registerForKeyboardNotifications()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    displayEmailField.becomeFirstResponder()
  }
  
  // MARK: - Actions
  
  @IBAction func actionButtonPressed() {
    signIn()
  }
  
  @IBAction func passwordViewPressed(){
    switch passwordView.selectedSegmentIndex{
    case 0:
      //unclicked
      hidePassword()
    case 1:
      //clicked
      showPassword()
    default:
      break
      
    }
    
  }
  
  @objc private func textFieldDidReturn() {
    signIn()
  }
  
  // MARK: - Helpers
  
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  private func showPassword(){
    displayPasswordField.isSecureTextEntry = false
  }
  
  private func hidePassword(){
    displayPasswordField.isSecureTextEntry = true
  }
  
  private func signIn() {
    guard let name = displayEmailField.text, !name.isEmpty else {
      showMissingNameAlert()
      return
    }
    //parameters to check against SQL when logging in
    let parameters: Parameters=[
       "email":displayEmailField.text!,
       "password":displayPasswordField.text!
      ]
     
//    Uses php files on server to post query to SQL databse
//    Query contains email and password
    Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON(){
       response in
       print(response)

       if let result = response.result.value{
         let jsonData = result as! NSDictionary

    //if no error (error = 0), allow login
        if (!(jsonData.value(forKey: "error") as! Bool)){
        self.displayEmailField.resignFirstResponder()

        //parse returned json containing first and last name and tier number

        let fName = (result as AnyObject).value(forKey: "firstName") as! String
        let lName = (result as AnyObject).value(forKey: "lastName") as! String
        let tierNumber = (result as AnyObject).value(forKey: "tierNumber") as? String
        let email = self.displayEmailField.text

        //concat first and last into full
        let fullName = "\(fName) \(lName)"

        //set default values for the user
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(tierNumber, forKey: "tierNumber")
        UserDefaults.standard.set(fullName, forKey: "fullName")

        AppSettings.displayName = fullName

        //verified with SQL, so create user in Firebase
        Auth.auth().createUser(withEmail: self.displayEmailField.text!, password: self.displayPasswordField.text!){(user, error) in
                if let e = error{
                  print(e)
                  print("error writing to Firebase")
                  return
                }else{
                  print("successfully created Firebase user")
                }
            }
        //set id to email in Firebase
        guard let id = self.displayEmailField.text else{
            print("error setting id")
                 return
                }
        //set tier number and full name in Firebase for channel creation
        self.db.collection("user-info").document(id).setData([
            "name": self.defaultValues.string(forKey: "fullName")!,
            "tier": self.defaultValues.integer(forKey: "tierNumber"),
            "email":self.defaultValues.string(forKey: "email")!])
      
        //sign in under new user
        Auth.auth().signIn(withEmail: self.displayEmailField.text!, password: self.displayPasswordField.text!, completion: nil)
          
          //assign user to tier in firestore
          if tierNumber == "1" {
            print("1")
            self.db.collection("tierOne").document("Users").collection("Users").document(email!).setData([
              "name": fullName,
              "email": email as Any])
          } else if tierNumber == "2" {
            print("tier 2")
            self.db.collection("tierTwo").document("Users").collection("Users").document(email!).setData([
              "name": fullName,
              "email": email as Any])
          } else {
            self.db.collection("tierThree").document("Users").collection("Users").document(email!).setData([
              "name": fullName,
              "email": email as Any])
          }
          
    //else login credentials failed
     }else{
       print("Check login information")
         }
       }
    }
  }
  
  private func showMissingNameAlert() {
    let ac = UIAlertController(title: "Display Name Required", message: "Please enter a display name.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
      DispatchQueue.main.async {
        self.displayEmailField.becomeFirstResponder()
      }
    }))
    present(ac, animated: true, completion: nil)
  }
  
  // MARK: - Notifications
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = keyboardHeight + 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}
