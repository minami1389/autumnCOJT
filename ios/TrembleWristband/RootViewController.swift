//
//  RootViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 1/31/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        if let twitterID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultTwitterIdKey) as? String  {
            SVProgressHUD.show()
            let user = User(twitterId: twitterID)
            user.fetchUserTwitterData({ () -> Void in
                UserManager.sharedInstance.setMe(user)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    self.performSegueWithIdentifier("rootToGame", sender: self)
                })
            })
        } else {
            SVProgressHUD.show()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                SVProgressHUD.dismiss()
                self.performSegueWithIdentifier("rootToLogin", sender: self)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
