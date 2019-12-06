
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class AppController {
  
  static let shared = AppController()
  
  init() {  
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userStateDidChange),
      name: Notification.Name.AuthStateDidChange,
      object: nil
    )
  }
  
  private var window: UIWindow!
  private var rootViewController: UIViewController? {
    didSet {
      if let vc = rootViewController {
        window.rootViewController = vc
      }
    }
  }
  
  // MARK: - Helpers
  
  func show(in window: UIWindow?) {
    guard let window = window else {
      fatalError("Cannot layout app with a nil window.")
    }
    
    FirebaseApp.configure()
    
    self.window = window
    window.tintColor = .primary
    window.backgroundColor = .white
    
    handleAppState()
    
    window.makeKeyAndVisible()
  }
  
  private func handleAppState() {
    if AppSettings.displayName == nil{
      print("inside display name check")
      do{
        try Auth.auth().signOut()
      } catch{
        print("error signing out")
      }
    }
    if let user = Auth.auth().currentUser {
      let vc = ChannelsViewController(currentUser: user)
      rootViewController = NavigationController(vc)
    } else {
      rootViewController = LoginViewController()
    }
  }
  
  // MARK: - Notifications
  
  @objc internal func userStateDidChange() {
    DispatchQueue.main.async {
      self.handleAppState()
    }
  }
  
}
