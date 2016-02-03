//
//  GameSettingViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 2/3/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreBluetooth

class GameSettingViewController: UIViewController {

    @IBOutlet weak var heartbeatSlider: UISlider!
    @IBOutlet weak var heartbeatSegment: UISegmentedControl!
    @IBOutlet weak var heartbeatLabel: UILabel!
    
    @IBOutlet weak var heartbeatUnitLabel: UILabel!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let heartbeatSegmentArray = ["以上", "以内"]
    let userDefault = NSUserDefaults.standardUserDefaults()
    
    var peripheralManager: CBPeripheralManager?
    var notifyCharacteristic: CBMutableCharacteristic?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        heartbeatSlider.addTarget(self, action: "didChangeValueHearatbeatSlider", forControlEvents: UIControlEvents.ValueChanged)
        distanceSlider.addTarget(self, action: "didChangeValueDistanceSlider", forControlEvents: UIControlEvents.ValueChanged)
        heartbeatSegment.addTarget(self, action: "didChangeValueHeartbeatSegment", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func didChangeValueHearatbeatSlider() {
        heartbeatLabel.text = "+\(Int(heartbeatSlider.value))"
    }
    
    func didChangeValueDistanceSlider() {
        distanceLabel.text = "\(Int(distanceSlider.value))"
    }
    
    func didChangeValueHeartbeatSegment() {
        heartbeatUnitLabel.text = "\(heartbeatSegmentArray[heartbeatSegment.selectedSegmentIndex])"
    }

    @IBAction func didTapCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func didTapDoneButton(sender: AnyObject) {
        guard let roomID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultRoomIdKey) as? String else { return }
        broadCastRoomNumberToOther(roomID)
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("measureVC") as? MeasureHeartBeatViewController {
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

    func broadCastRoomNumberToOther(roomId: String) {
        guard let value = "createRoom:\(roomId)".dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let notifyCharacteristic = self.notifyCharacteristic else { return }
        self.peripheralManager?.updateValue(value, forCharacteristic: notifyCharacteristic, onSubscribedCentrals: nil)
    }

}
