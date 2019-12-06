//
//  Options.swift
//  RWRC
//
//  Created by Kira Bowden on 11/8/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit

protocol OptionsItem {
  var text: String {get}
  var isSelected: Bool {get}
  var font: UIFont {get set}
}

extension OptionsItem{
  func sizeForDisplayText()-> CGSize{
    return text.size(withAttributes: [NSAttributedString.Key.font: font])
  }
}
