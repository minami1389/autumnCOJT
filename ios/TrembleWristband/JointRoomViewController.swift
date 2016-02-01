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
    
    var centralManager: CBCentralManager?
    var asobiPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    var notifyCharacteristic: CBCharacteristic?
   
    var asobiPeripherals = [CBPeripheral]()
    
    var users = [User]()
    var accepted = false
    var twitterId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        twitterId = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultTwitterIdKey) as? String
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
            if localName.hasPrefix("asobeat:") {
                let twitterId = localName.substringFromIndex(8)
                let user = User(twitterId: twitterId)
                if  user.containsUsers(users) == false {
                    users.append(user)
                    asobiPeripherals.append(peripheral)
                    user.fetchUserTwitterData({
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    })
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
        if let asobiPeripheral = asobiPeripheral {
            centralManager?.cancelPeripheralConnection(asobiPeripheral)
            guard let notifyCharacteristic = notifyCharacteristic else { return }
            asobiPeripheral.setNotifyValue(false, forCharacteristic: notifyCharacteristic)
        }
        asobiPeripheral = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            print("didDiscoverServicesError: \(error)")
            return
        }
        let services = peripheral.services!
        for service in services {
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            print("didDiscoverCharacteristicsError: \(error)")
            return
        }
        let characteristics = service.characteristics!
        for characteristic in characteristics {
            if characteristic.UUID.isEqual(kWriteCharacteristicUUID) {
                writeCharacteristic = characteristic
                guard let value = twitterId?.dataUsingEncoding(NSUTF8StringEncoding) else { return }
                guard let writeCharacteristic = writeCharacteristic else { return }
                asobiPeripheral?.writeValue(value, forCharacteristic: writeCharacteristic, type: .WithResponse)
            } else if characteristic.UUID.isEqual(kNotifyCharacteristicUUID) {
                notifyCharacteristic = characteristic
                guard let notifyCharacteristic = notifyCharacteristic else { return }
                asobiPeripheral?.setNotifyValue(true, forCharacteristic: notifyCharacteristic)
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
        guard let value = characteristic.value else { return }
        let characteristicValue = String(data: value, encoding: NSUTF8StringEncoding)
        if characteristicValue == twitterId {
            accepted = true
            SVProgressHUD.showWithStatus("リクエストが承認されました\n他のメンバーを待っています", maskType: .Gradient)
        } else if characteristicValue?.hasPrefix("createRoom:") == true {
            if accepted {
                guard let roomNumber = characteristicValue?.componentsSeparatedByString(":")[1] else { return }
                NSUserDefaults.standardUserDefaults().setObject(roomNumber, forKey: kUserDefaultRoomIdKey)
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("measureVC") as? MeasureHeartBeatViewController {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
                
            } else {
                SVProgressHUD.showErrorWithStatus("リクエストが承認されませんでした")
            }
        }
    }
    
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HostUserCell") as! HostUserTableViewCell
        let user = users[indexPath.row]
        cell.iconImageView.image = user.image
        cell.nameLabel.text = user.name
        cell.idLabel.text = user.screenName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        if let name = user.screenName {
            SVProgressHUD.showWithStatus("\(name)さんに\nリクエスト中", maskType: .Gradient)
        }
        asobiPeripheral = asobiPeripherals[indexPath.row]
        asobiPeripheral?.delegate = self
        guard let asobiPeripheral = asobiPeripheral else { return }
        centralManager?.connectPeripheral(asobiPeripheral, options: nil)
    }
}