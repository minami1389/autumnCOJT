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
    var heartBeatCharacteristic: CBCharacteristic!
    var vibrationCharacteristic: CBCharacteristic!
    
    var measureTimer:NSTimer?
    var resultHeartBeat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
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
                if asobiPeripheral != nil {
                    centralManager?.connectPeripheral(asobiPeripheral!, options: nil)
                }
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
        centralManager?.cancelPeripheralConnection(asobiPeripheral!)
        asobiPeripheral?.setNotifyValue(false, forCharacteristic: heartBeatCharacteristic)
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
            print("service:\(service)")
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
                print("discoverHeartBeat")
                heartBeatCharacteristic = characteristic
                asobiPeripheral!.setNotifyValue(true, forCharacteristic: heartBeatCharacteristic)
                if let value = characteristic.value {
                    let characteristicValue = String(data: value, encoding: NSUTF8StringEncoding)
                    print("HeartBeat:\(characteristicValue)")
                }
                if measureTimer == nil {
                    measureTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "checkHeartBeat", userInfo: nil, repeats: false)
                }
            } else if characteristic.UUID.isEqual(kVibrationCharacteristicUUID) {
                print("discoverVibration")
                vibrationCharacteristic = characteristic
            }
        }
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
        print("resultHeartBeat:\(resultHeartBeat)")
        NSUserDefaults.standardUserDefaults().setInteger(resultHeartBeat, forKey: "heartBeat")
        asobiPeripheral?.writeValue("1".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: vibrationCharacteristic, type: .WithResponse)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.asobiPeripheral?.writeValue("0".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: self.vibrationCharacteristic, type: .WithResponse)
        }
    }
    
    @IBAction func didPushMeasureButton(sender: AnyObject) {
//        let userDefault = NSUserDefaults.standardUserDefaults()
//        userDefault.setFloat(resultHeartBeat, forKey: "heartBeat")
//        self.performSegueWithIdentifier("measureToPlay", sender: self)
        checkHeartBeat()
    }

}
