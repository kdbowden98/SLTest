import Foundation
import UIKit
class ProgressCell: UITableViewCell {
  
  let completedLabel = UILabel()
  var link: ProgressController?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    completedLabel.text = "Not Completed"
    completedLabel.textColor = .red
    completedLabel.adjustsFontSizeToFitWidth = true
    
    completedLabel.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
    accessoryView = completedLabel
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

