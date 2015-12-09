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
    
    init(id: String, name: String, screenName: String, image: UIImage) {
        super.init()
        self.id = id
        self.name = name
        self.screenName = screenName
        self.image = image
    }
}
