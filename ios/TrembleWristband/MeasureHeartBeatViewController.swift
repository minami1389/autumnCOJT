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

    var centralManager: CBCentralManager!
    var asobiPeripheral: CBPeripheral!
    var heartBeatCharacteristic: CBCharacteristic!
    var vibrationCharacteristic: CBCharacteristic!
    
    var measureTimer:NSTimer!
    var resultHeartBeat:Float = 0
    
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
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let localName = advertisementData["kCBAdvDataLocalName"] as? NSString {
            if localName.hasPrefix("asobeatDevice") {
                asobiPeripheral = peripheral
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected")
        asobiPeripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Connect error...")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnect")
        centralManager.cancelPeripheralConnection(asobiPeripheral)
        asobiPeripheral = nil
        asobiPeripheral.setNotifyValue(false, forCharacteristic: heartBeatCharacteristic)
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
                asobiPeripheral.setNotifyValue(true, forCharacteristic: heartBeatCharacteristic)
                let characteristicValue = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
                print("HeartBeat:\(characteristicValue)")
                if measureTimer == nil {
                    measureTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "checkHeartBeat", userInfo: nil, repeats: false)
                }
            } else if characteristic.UUID.isEqual(kVibrationCharacteristicUUID) {
                vibrationCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("write:\(error)")
            return
        }
        print("did write")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
            let value = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            print("heartBeat:\(value)")
            if let heartBeat = value {
                resultHeartBeat = (resultHeartBeat+Float(heartBeat)!)/2
            }
        }
    }
    
    func checkHeartBeat() {
        print("resultHeartBeat:\(resultHeartBeat)")
        let message = "didMeasureHeartBeat"
        asobiPeripheral.writeValue(message.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: vibrationCharacteristic, type: .WithResponse)
    }
    
    @IBAction func didPushMeasureButton(sender: AnyObject) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setFloat(resultHeartBeat, forKey: "heartBeat")
        self.performSegueWithIdentifier("measureToPlay", sender: self)
    }

}
