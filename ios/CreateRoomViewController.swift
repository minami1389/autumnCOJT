//
//  CreateRoomViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreBluetooth
import TwitterKit


//Peripheral

class CreateRoomViewController: UIViewController, CBPeripheralManagerDelegate {

    let serviceUUID = CBUUID(string: "632D50CB-9DC0-496C-8E28-19F4E0AA0DBC")
    let characteristicUUID = CBUUID(string: "DF89A6DD-DC47-4C5C-8147-1141C62E1B04")

    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!

    var userId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey:true]);
        let userDefault = NSUserDefaults.standardUserDefaults()
        userId = String(userDefault.valueForKey("userId")!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.peripheralManager.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn { return }
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: CBCharacteristicProperties.Read, value: userId.dataUsingEncoding(NSUTF8StringEncoding)!, permissions: CBAttributePermissions.Readable)
        service.characteristics = [characteristic]
        peripheralManager.addService(service)
        let localName = "asobeat:" + userId
        let advertisingData = [CBAdvertisementDataLocalNameKey:localName]
        peripheralManager.startAdvertising(advertisingData)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            print("Failed...error:\(error)")
        }
        print("Succeeded!")
        print(peripheral.description)
    }
    
    
    
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

   
}
