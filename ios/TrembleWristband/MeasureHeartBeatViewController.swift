//
//  MeasureHeartBeatViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/18/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import SVProgressHUD

class MeasureHeartBeatViewController: UIViewController {

    var measureTimer:NSTimer?
    
    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var measureButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var heartBgImageView: UIImageView!
    
    let deviceManager = DeviceManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heartImageView.image = UIImage.fontAwesomeIconWithName(.Heartbeat, textColor: UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 0.5), size: CGSizeMake(220, 220)).imageWithRenderingMode(.AlwaysOriginal)
        heartBgImageView.image = UIImage.fontAwesomeIconWithName(.Heartbeat, textColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), size: CGSizeMake(220, 220)).imageWithRenderingMode(.AlwaysOriginal)
        setHeartBeatLabelText("0")
        
        let attrText = NSMutableAttributedString(string: "bpm")
        attrText.addAttributes([NSStrokeColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:-1.0], range: NSRange(location: 0, length: attrText.length))
        bpmLabel.attributedText = attrText
        
        guard let deviceID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultDeviceIDKey) as? String else { return }
        deviceManager.reset()
        deviceManager.setup(deviceID, didDiscoverDevice: { () -> Void in
            SVProgressHUD.dismiss()
            self.stateLabel.text = "Device発見"
            self.measureButton.hidden = false
            self.measureButton.setTitle("計測開始", forState: .Normal)
            }) { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.showWithMaskType(.Gradient)
        stateLabel.text = "Device探索中"
        measureButton.hidden = true
        measureButton.setTitle("", forState: .Normal)
    }
    
    func checkHeartBeat() {
        SVProgressHUD.dismiss()
        stateLabel.text = "計測完了"
        measureButton.setTitle("Let`s Asobeat!!", forState: .Normal)
        let heartbeat = deviceManager.getHeaertbeat()
        setHeartBeatLabelText(String("69"))
        NSUserDefaults.standardUserDefaults().setInteger(heartbeat, forKey: kUserDefaultHeartBeatKey)
        deviceManager.vibrate(1)
    }
    
    func setHeartBeatLabelText(text:String) {
        let attrText = NSMutableAttributedString(string: text)
        attrText.addAttributes([NSStrokeColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:-1.0], range: NSRange(location: 0, length: attrText.length))
        heartBeatLabel.attributedText = attrText
    }
    
    @IBAction func didPushMeasureButton(sender: AnyObject) {
        if stateLabel.text == "Device発見" {
            SVProgressHUD.showWithMaskType(.Gradient)
            stateLabel.text = "計測中"
            if measureTimer == nil {
                measureTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "checkHeartBeat", userInfo: nil, repeats: false)
            }
        } else if stateLabel.text == "計測完了" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PlayGameVC") as! PlayGameViewController
            self.presentViewController(vc, animated: true, completion: nil)
            deviceManager.stopScan()
        }
    }
    
}
