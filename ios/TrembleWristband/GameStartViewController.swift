//
//  GameStartViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class GameStartViewController: UIViewController, UIScrollViewDelegate {
   
    @IBOutlet weak var createTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setShowdow(createTeamButton)
        setShowdow(joinTeamButton)
        setShowdow(logoutButton)
        setShowdow(userInfoView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let me = UserManager.sharedInstance.getMe()
        userNameLabel.text = me?.name
        if let screenName = me?.screenName {
            userScreenNameLabel.text = "@\(screenName)"
        }
        userImageView.image = me?.image
    }
    
    func setShowdow(view:UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 1.0
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.darkGrayColor().CGColor
    }
    
//IBAction
    @IBAction func didTapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPushedCreateRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toCreateRoomVC", sender: self)
    }

    @IBAction func didPushedJoinRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toJoinRoomVC", sender: self)
    }
    @IBAction func didPushLogoutButton(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultTwitterIdKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        UIApplication.sharedApplication().keyWindow?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootVC")
    }
    
}
