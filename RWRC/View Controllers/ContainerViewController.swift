//
//  ContainerViewController.swift
//  RWRC
//
//  Created by Kira Bowden on 11/8/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit

class ContainerViewController: UINavigationController{
  enum slideOutState {
    case panelExpanded
    case collapsed
  }
  
  var centerNavigationController: UINavigationController!
  var centerViewController: CenterViewController!
  
  var currentState: slideOutState = .collapsed{
    didSet{
      let shouldShowShadow = currentState != .collapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  
  var 
}
