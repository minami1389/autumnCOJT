//
//  GameStartViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class GameStartViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userDefault = NSUserDefaults.standardUserDefaults()
        let userName = userDefault.valueForKey("userName")
        let userId = userDefault.valueForKey("userID")
        userNameLabel.text = String(userName!)
        print(userId)
    }

    @IBAction func didTapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    @IBAction func didPushedCreateRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toCreateRoomVC", sender: self)
    }
    

    @IBAction func didPushedJoinRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toJoinRoomVC", sender: self)
    }
}
