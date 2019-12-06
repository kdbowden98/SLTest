import UIKit

class Menu: NSObject{
  let name: String
  let imageName: String
  
  init(name: String, imageName: String) {
    self.name = name
    self.imageName = imageName
  }
}

class MenuLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
  
  let backgroundView = UIView()
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = UIColor.white
    return cv
  }()
  
  let cellId = "cellId"
  let cellHeight: CGFloat = 60
  
  let menus: [Menu] = {
    return [Menu(name: "Messages", imageName: "Messaging"),
            Menu(name: "Events", imageName: "events"),
            Menu(name: "Progress", imageName: "progress"),
            Menu(name: "Profile", imageName: "profile"),
            Menu(name: "Cancel", imageName: "cancel")]
  }()
  
  var channelController: ChannelsViewController?
  
  @objc func handleMenu(){
    //black background view
    if let window = UIApplication.shared.keyWindow {
      backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
      
      backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
      
      window.addSubview(backgroundView)
      window.addSubview(collectionView)
      
      let height: CGFloat = CGFloat(menus.count) * cellHeight
      let y = window.frame.height - height
      collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
  
      backgroundView.frame = window.frame
      backgroundView.alpha = 0
      
      UIView.animate(withDuration: 0.5, animations: {
        self.backgroundView.alpha = 1
        self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
      })
    }
  }
  
  //dismiss background view
  @objc func handleDismiss(){
    UIView.animate(withDuration: 0.5, animations: {
      self.backgroundView.alpha = 0
      if let window = UIApplication.shared.keyWindow{
        self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
      }
    })
    
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return menus.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
    let menu = menus[indexPath.item]
    cell.menu = menu
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.backgroundView.alpha = 0
        if let window = UIApplication.shared.keyWindow{
          self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }
    }) { (completed: Bool) in
      let menu = self.menus[indexPath.item]
      self.channelController?.showController(menu: menu)
    }
    
  }
  
  override init(){
    super.init()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
  }
}
