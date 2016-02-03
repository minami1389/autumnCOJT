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
    @IBOutlet weak var createTeamArrow: UIImageView!
    @IBOutlet weak var joinTeamArrow: UIImageView!
    
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
        
        navigationItem.titleView =  UIImageView(image: UIImage.fontAwesomeIconWithName(.Home, textColor: UIColor(red: 3/255, green: 169/255, blue: 244/255, alpha: 1.0), size: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysOriginal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(.Tablet, textColor: UIColor(red: 3/255, green: 169/255, blue: 244/255, alpha: 1.0), size: CGSizeMake(30, 30)).imageWithRenderingMode(.AlwaysOriginal), style:.Plain, target: self, action: "didTapSettingButton")
        
        
        createTeamArrow.image = UIImage.fontAwesomeIconWithName(.HandPointerO, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysOriginal)
        joinTeamArrow.image = UIImage.fontAwesomeIconWithName(.HandPaperO, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysOriginal)
    }
    
    func didTapSettingButton() {
        let deviceSettingVC = self.storyboard?.instantiateViewControllerWithIdentifier("DeviceSettingVC") as! DeviceSettingViewController
        presentViewController(deviceSettingVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let me = UserManager.sharedInstance.getMe()
        userNameLabel.text = me?.name
        userScreenNameLabel.text = me?.screenName
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
    
    @IBAction func didPushLogoutButton(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultTwitterIdKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        UIApplication.sharedApplication().keyWindow?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootVC")
    }
    
}
