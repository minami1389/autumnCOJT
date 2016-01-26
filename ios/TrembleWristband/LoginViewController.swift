//
//  LoginViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoginButton()
    }
    
    func createLoginButton() {
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                self.didLoggedIn(unwrappedSession)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        logInButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y+150)
        logInButton.layer.borderColor = UIColor.whiteColor().CGColor
        logInButton.layer.borderWidth = 1.0
        self.view.addSubview(logInButton)
    }
    
    func didLoggedIn(session:TWTRSession) {
        APIManager.sharedInstance.createUser(session.userID) { (user) -> Void in
            user.fetchUserTwitterData({
                UserManager.sharedInstance.setMe(user)
                NSUserDefaults.standardUserDefaults().setObject(user.twitterId, forKey: kUserDefaultTwitterIdKey)
                NSUserDefaults.standardUserDefaults().setObject(user.twitterId, forKey: kUserDefaultUserIdKey)
                self.showDidLoginAlert(session.userName)
            })
        }
    }
    
    func showDidLoginAlert(userName: String) {
        let alert = UIAlertController(title: "ログイン",
            message: "\(userName)でログインしました",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler: { (action:UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("toGameStartVC", sender: self)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
