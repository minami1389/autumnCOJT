//
//  LoginViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoginButton()
        attributeTitle()
        titleLabel.highlighted = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleLabel.hidden = false
        titleLabel.transform = CGAffineTransformMakeScale(1/2, 1/2)
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 3, 3)

            }) { (success) -> Void in
                UIView.animateWithDuration(0.5) { () -> Void in
                    self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 2/3, 2/3)
                }
        }
    }
    
    func attributeTitle() {
        let attrText = NSMutableAttributedString(string: titleLabel.text!)
        attrText.addAttributes([NSForegroundColorAttributeName:UIColor(red: 255/255, green: 145/255, blue: 0/255, alpha: 1.0), NSStrokeColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:-0.5], range: NSRange(location: 0, length: 1))
        attrText.addAttributes([NSForegroundColorAttributeName:UIColor(red: 245/255, green: 0/255, blue: 87/255, alpha: 1.0), NSStrokeColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:-0.5], range: NSRange(location: 3, length: 1))
        titleLabel.attributedText = attrText

    }
    
    func createLoginButton() {
        let logInButton = TWTRLogInButton { (session, error) in
        }
        logInButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y+40)
        logInButton.layer.borderColor = UIColor.whiteColor().CGColor
        logInButton.layer.borderWidth = 1.0
        self.view.addSubview(logInButton)
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapLoginButton")
        logInButton.addGestureRecognizer(tapGesture)
    }
    
    func didTapLoginButton() {
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.showWithMaskType(.Gradient)
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            if let unwrappedSession = session {
                self.didLoggedIn(unwrappedSession)
            } else {
                SVProgressHUD.dismiss()
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
    }
    
    func didLoggedIn(session:TWTRSession) {
        APIManager.sharedInstance.fetchUser(session.userID) { (user) -> Void in
            if let _ = user {
                self.setMe(session)
                return
            }
            APIManager.sharedInstance.createUser(session.userID) { (user) -> Void in
                self.setMe(session)
            }
        }
    }
    
    func setMe(session: TWTRSession) {
        let user = User(twitterId: session.userID)
        user.fetchUserTwitterData { () -> Void in
            UserManager.sharedInstance.setMe(user)
            NSUserDefaults.standardUserDefaults().setObject(session.userID, forKey: kUserDefaultTwitterIdKey)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3))
                SVProgressHUD.showSuccessWithStatus("ログイン完了", maskType: .Gradient)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.presentToNextVC()
                }
            })
        }
    }
    
    func presentToNextVC() {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultDeviceIDKey) as? String  {
            self.performSegueWithIdentifier("toGameStartVC", sender: self)
        } else {
            self.performSegueWithIdentifier("toRegisterDeviceVC", sender: self)
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
