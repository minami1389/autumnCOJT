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

class JointRoomViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressCoverView: UIView!
    
    var centralManager: CBCentralManager!
    var asobiPeripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var notifyCharacteristic: CBCharacteristic!
   
    var asobiPeripherals = [CBPeripheral]()
    
    var users = [User]()
    var userId = ""
    var accepted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        SVProgressHUD.setBackgroundColor(UIColor.blackColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        userId = String(userDefault.valueForKey("userId")!)
    }

    override func viewWillDisappear(animated: Bool) {
        SVProgressHUD.dismiss()
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
            if localName.hasPrefix("asobeat:") {
                let twitterId = localName.substringFromIndex(8)
                let user = User(twitterId: twitterId)
                if  user.containsUsers(users) == false {
                    users.append(user)
                    asobiPeripherals.append(peripheral)
                    user.fetchHostUserTwitterData({
                        self.tableView.reloadData()
                    })
                }
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
        asobiPeripheral.setNotifyValue(false, forCharacteristic: notifyCharacteristic)
        asobiPeripheral = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
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
            if characteristic.UUID.isEqual(kWriteCharacteristicUUID) {
                writeCharacteristic = characteristic
                asobiPeripheral.writeValue(userId.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: writeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            } else if characteristic.UUID.isEqual(kNotifyCharacteristicUUID) {
                notifyCharacteristic = characteristic
                asobiPeripheral.setNotifyValue(true, forCharacteristic: notifyCharacteristic)
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
        let characteristicValue = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        if characteristicValue == userId {
            accepted = true
            SVProgressHUD.showWithStatus("リクエストが承認されました\n他のメンバーを待っています")
        } else if characteristicValue?.hasPrefix("createRoom:") == true {
            if accepted {
                let roomNumber = characteristicValue?.componentsSeparatedByString(":")[1]
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(roomNumber!, forKey: "roomNumber")
                self.performSegueWithIdentifier("joinToMeasure", sender: self)
            } else {
                SVProgressHUD.showErrorWithStatus("リクエストが承認されませんでした")
            }
        }
    }
    
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
//TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HostUserCell") as! HostUserTableViewCell
        let user = users[indexPath.row]
        cell.iconImageView.image = user.image
        cell.nameLabel.text = user.screenName
        cell.idLabel.text = user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row] 
        SVProgressHUD.showWithStatus("\(user.screenName)さんに\nリクエスト中")
        progressCoverView.hidden = false
        asobiPeripheral = asobiPeripherals[indexPath.row]
        asobiPeripheral.delegate = self
        centralManager.connectPeripheral(asobiPeripheral, options: nil)
    }
}