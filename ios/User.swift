//
//  User.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/9/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

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
}
