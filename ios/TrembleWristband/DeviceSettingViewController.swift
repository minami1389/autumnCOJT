//
//  DeviceSettingViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 2/3/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import UIKit

class DeviceSettingViewController: UIViewController {

    @IBOutlet weak var deviceIDTitleLabel: UILabel!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let deviceID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultDeviceIDKey) as? String {
            deviceIDTitleLabel.hidden = false
            deviceIDLabel.text = deviceID
            registerButton.setTitle("登録解除", forState: .Normal)
        } else {
            deviceIDTitleLabel.hidden = true
            deviceIDLabel.text = "デバイスが\n登録されていません"
            registerButton.setTitle("再登録", forState: .Normal)
        }

    }

    func isRegisterDevice() -> Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultDeviceIDKey) as? String {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLayoutSubviews() {
        deviceImageView.image = UIImage.fontAwesomeIconWithName(.Tablet, textColor: UIColor.whiteColor(), size: CGSizeMake(deviceImageView.frame.width, deviceImageView.frame.height))
    }
    
    @IBAction func didTapCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapRegisterButton(sender: AnyObject) {
        if isRegisterDevice() {
            showConfirmRelease()
        } else {
            let registerDeviceVC = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterDeviceVC") as! RegisterDeviceViewController
            self.presentViewController(registerDeviceVC, animated: true, completion: nil)
        }
    }
    
    func showConfirmRelease() {
        let alert = UIAlertController(title: "確認", message: "デバイス登録を解除してよろしいですか", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "解除", style: .Default, handler: { (action) -> Void in
            guard let deviceID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultDeviceIDKey) as? String else { return }
            APIManager.sharedInstance.deleteDevice(deviceID, completion: { () -> Void in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultDeviceIDKey)
                self.showCompleteRelease()
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showCompleteRelease() {
        let alert = UIAlertController(title: "完了", message: "デバイス登録を解除しました", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
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
