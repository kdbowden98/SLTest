//
//  BaseCell.swift
//  RWRC
//
//  Created by Kira Bowden on 11/8/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell{
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  func setupViews(){
    
  }
  
  required init?(coder aDecoder: NSCoder){
    fatalError("init coder has not been implemented")
  }
}
