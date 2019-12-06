//
//  TableViewExtension.swift
//  RWRC
//
//  Created by Kira Bowden on 11/8/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit

extension UITableViewCell{
  func configure(with optionItem: OptionsItem){
    textLabel?.text = optionItem.text
    textLabel?.font = optionItem.font
    accessoryType = optionItem.isSelected ? .checkmark: .none
  }
}
