//
//  JointRoomViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreBluetooth
import TwitterKit


//Central

class JointRoomViewController: UIViewController, CBCentralManagerDelegate {

    let serviceUUID = CBUUID(string: "632D50CB-9DC0-496C-8E28-19F4E0AA0DBC")
    let characteristicUUID = CBUUID(string: "DF89A6DD-DC47-4C5C-8147-1141C62E1B04")

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        fetchHostUserData("412063232")
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state != CBCentralManagerState.PoweredOn { return }
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("discover:\(peripheral.description)")
        print(advertisementData)
    }

    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func fetchHostUserData(twitterId: String) {
        let client = Twitter.sharedInstance().APIClient
        client.loadUserWithID(twitterId, completion: { (user, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                let iconUrl = NSURL(string: (user?.profileImageLargeURL)!)
                let iconData = NSData(contentsOfURL: iconUrl!)
                let iconImage = UIImage(data: iconData!)
                print(user?.userID)
                print(user?.name)
                print(user?.screenName)
            }
        })
        
    }
}