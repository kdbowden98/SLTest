//
//  DBLogin.swift
//  RWRC
//
//  Created by Kira Bowden on 11/1/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import Foundation

protocol HomeModelProtocol: class {
  func itemsDownloaded(items: NSArray)
}

class DBLogin: NSObject, URLSessionDataDelegate {
  weak var delegate: HomeModelProtocol!
  
  var data = Data()
  
  let urlPath: String = "http://3.84.5.233/service.php"
  
  func downloadItems(){
    let url: URL = URL(string: urlPath)!
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)

    let task = defaultSession.dataTask(with: url){
      (data, response, error) in
      if error != nil {
        print("failed to download")
      } else{
        print("download successful")
        self.parseJSON(data!)
      }
    }
    task.resume()
  }
  
  func parseJSON(_ data: Data){
    var jsonResult = NSArray()
    
    do{
      jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
    } catch let error as NSError {
      print(error)
    }
    
    var jsonElement = NSDictionary()
    var logins = NSMutableArray()
    
    for i in 0 ..< jsonResult.count{
      jsonElement = jsonResult[i] as! NSDictionary
      
      let login = LoginModel()
      
      if let email = jsonElement["email"] as? String,
        let password = jsonElement["password"] as? String,
        let tierNumber = jsonElement["tierNumber"] as? Int
      {
        login.email = email
        login.password = password
        login.tierNumber = tierNumber
      }
      logins.add(login)
    }
    
    DispatchQueue.main.async(execute: { () -> Void in
      self.delegate.itemsDownloaded(items: logins)
    })
  }
}
