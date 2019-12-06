//
//  LoginModel.swift
//  RWRC
//
//  Created by Kira Bowden on 11/1/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import Foundation

class LoginModel: NSObject {
  var email: String?
  var password: String?
  var tierNumber: Int?
  
  override init(){
  }
  
  init(email: String, password: String, tierNumber: Int ){
    self.email = email;
    self.password = password;
    self.tierNumber = tierNumber;
  }
  
  override var description: String {
    return "Email: \(email), password: \(password), tier number: \(tierNumber)"
  }
}
