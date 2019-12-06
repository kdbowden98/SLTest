//
//  MenuCell.swift
//  RWRC
//
//  Created by Kira Bowden on 11/8/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit

class MenuCell: BaseCell{
  
  var menu: Menu?{
    didSet{
      nameLabel.text = menu?.name
      
      if let imageName = menu?.imageName{
        iconImageView.image = UIImage(named: imageName)
      }
    }
  }
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Messages"
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Messaging")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  override func setupViews() {
    super.setupViews()
    
    addSubview(nameLabel)
    addSubview(iconImageView)
    
    addConstraintsWithFormat(format: "H:|-16-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)
    addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
    addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
    
    addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    
    
  }
}

extension UIView{
  func addConstraintsWithFormat(format: String, views: UIView...){
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated(){
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewsDictionary[key] = view
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
  }
}
