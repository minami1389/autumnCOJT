//
//  User.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/9/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit

class User: NSObject {

    var id = ""
    var name = ""
    var screenName = ""
    var image:UIImage!
    
    init(id: String) {
        super.init()
        self.id = id
    }
    
    func containsUsers(users:NSArray) -> Bool {
        for obj in users {
            if let user = obj as? User {
                if user.id == self.id { return true }
            }
        }
        return false
    }
    
    func fetchHostUserData(completion:()->Void) {
        let client = Twitter.sharedInstance().APIClient
        client.loadUserWithID(self.id, completion: { (obj, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                do {
                    let iconUrl = NSURL(string: (obj?.profileImageURL)!)
                    let iconData = try NSData(contentsOfURL: iconUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    let image = UIImage(data: iconData)
                    self.name = (obj?.name)!
                    self.screenName = (obj?.screenName)!
                    self.image = image
                    completion()
                } catch {
                    print("error")
                }
            }
        })
    }
}
