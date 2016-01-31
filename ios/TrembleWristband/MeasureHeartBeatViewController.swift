//
//  MeasureHeartBeatViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/18/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeasureHeartBeatViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager?
    var asobiPeripheral: CBPeripheral?
    var heartBeatCharacteristic: CBCharacteristic?
    var vibrationCharacteristic: CBCharacteristic?
    
    var measureTimer:NSTimer?
    var resultHeartBeat = 60
    
    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var measureButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        if let image = UIImage(named: "bg.png") {
            view.backgroundColor = UIColor(patternImage: image)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.showWithMaskType(.Gradient)
        stateLabel.text = "Device探索中"
        measureButton.setTitle("", forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        didPrepareMeasure()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state != CBCentralManagerState.PoweredOn {
            print("PoweredOff")
            return
        }
        print("PoweredOn")
        centralManager?.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let localName = advertisementData["kCBAdvDataLocalName"] as? NSString {
            if localName.hasPrefix("asobeatDevice") {
                asobiPeripheral = peripheral
                asobiPeripheral?.delegate = self
                guard let asobiPeripheral = asobiPeripheral else { return }
                centralManager?.connectPeripheral(asobiPeripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected")
        asobiPeripheral?.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Connect error...")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnect")
        if let asobiPeripheral = asobiPeripheral {
            guard let heartBeatCharacteristic = heartBeatCharacteristic else { return }
            centralManager?.cancelPeripheralConnection(asobiPeripheral)
            asobiPeripheral.setNotifyValue(false, forCharacteristic: heartBeatCharacteristic)
        }
        heartBeatCharacteristic = nil
        vibrationCharacteristic = nil
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            print("error: \(error)")
            return
        }
        let services = peripheral.services!
        for service in services {
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            print("error: \(error)")
            return
        }
        let characteristics = service.characteristics!
        for characteristic in characteristics {
            if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
                heartBeatCharacteristic = characteristic
                guard let heartBeatCharacteristic = heartBeatCharacteristic else { return }
                asobiPeripheral?.setNotifyValue(true, forCharacteristic: heartBeatCharacteristic)
                didPrepareMeasure()
            } else if characteristic.UUID.isEqual(kVibrationCharacteristicUUID) {
                vibrationCharacteristic = characteristic
            }
        }
    }
    
    func didPrepareMeasure() {
        SVProgressHUD.dismiss()
        stateLabel.text = "Device発見"
        measureButton.setTitle("計測開始", forState: .Normal)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("write:\(error)")
            return
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
            if let value = characteristic.value {
                var heartBeat: NSInteger = 0
                value.getBytes(&heartBeat, length: sizeof(NSInteger))
                print("heartBeat:\(heartBeat)")
                resultHeartBeat = (resultHeartBeat+heartBeat)/2
            }
        }
    }
    
    func checkHeartBeat() {
        SVProgressHUD.dismiss()
        stateLabel.text = "計測完了"
        measureButton.setTitle("Let`s Asobeat!!", forState: .Normal)
        heartBeatLabel.text = "\(resultHeartBeat)"
        print("resultHeartBeat:\(resultHeartBeat)")
        NSUserDefaults.standardUserDefaults().setInteger(resultHeartBeat, forKey: kUserDefaultHeartBeatKey)
        switchVibration(true)
        //showCompleteMeasureAlert()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.switchVibration(false)
        }
    }
    
    func switchVibration(on: Bool) {
        var switchValue = "0"
        if on { switchValue = "1" }
        guard let value = switchValue.dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let vibrationCharacteristic = vibrationCharacteristic else { return }
        asobiPeripheral?.writeValue(value, forCharacteristic: vibrationCharacteristic, type: .WithResponse)
    }
    
    func showCompleteMeasureAlert() {
        let alert = UIAlertController(title: "計測完了", message: "あなたの通常時心拍は\(resultHeartBeat)です", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
            self.performSegueWithIdentifier("measureToPlay", sender: self)
            let playGameVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlayGameVC") as! PlayGameViewController
            playGameVC.asobiPeripheral = self.asobiPeripheral
            playGameVC.heartBeatCharacteristic = self.heartBeatCharacteristic
            playGameVC.vibrationCharacteristic = self.vibrationCharacteristic
            self.presentViewController(playGameVC, animated: true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }

    
    @IBAction func didPushMeasureButton(sender: AnyObject) {
        if stateLabel.text == "Device発見" {
            SVProgressHUD.showWithMaskType(.Gradient)
            stateLabel.text = "計測中"
            if measureTimer == nil {
                measureTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkHeartBeat", userInfo: nil, repeats: false)
            }
        } else if stateLabel.text == "計測完了" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PlayGameVC") as! PlayGameViewController
            vc.asobiPeripheral = asobiPeripheral
            vc.heartBeatCharacteristic = heartBeatCharacteristic
            vc.vibrationCharacteristic = vibrationCharacteristic
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

}
