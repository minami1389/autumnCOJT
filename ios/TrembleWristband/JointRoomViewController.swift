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
    
    let serviceUUID = CBUUID(string: "632D50CB-9DC0-496C-8E28-19F4E0AA0DBC")
    let characteristicUUID = CBUUID(string: "DF89A6DD-DC47-4C5C-8147-1141C62E1B04")

    var centralManager: CBCentralManager!
    var asobiPeripheral: CBPeripheral!
    var asobiCharacteristic: CBCharacteristic!
   
    var asobiPeripherals = [CBPeripheral]()
    
    var users: NSMutableArray = []

    var isRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        SVProgressHUD.setBackgroundColor(UIColor.blackColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
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
        print("discover:\(peripheral.description)")
        print("advertise:\(advertisementData)")
        let localName = advertisementData["kCBAdvDataLocalName"] as? NSString
        print(localName)
        if let localName = advertisementData["kCBAdvDataLocalName"] as? NSString {
            if localName.hasPrefix("asobeat:") {
                let twitterId = localName.substringFromIndex(8)
                let user = User(id: twitterId)
                if  user.containsUsers(users) == false {
                    print("asobeat user")
                    users.addObject(user)
                    asobiPeripherals.append(peripheral)
                    fetchHostUserData(user)
                }
            }
        }
//        asobiPeripheral = peripheral
//        asobiPeripheral.delegate = self
//        centralManager.connectPeripheral(asobiPeripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
            print("Connect error...")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnect")
        centralManager.cancelPeripheralConnection(asobiPeripheral)
        asobiPeripheral = nil
        asobiCharacteristic = nil
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
            if characteristic.UUID.isEqual(characteristicUUID) {
                asobiCharacteristic = characteristic
                print("characteristic:\(characteristic)")
                asobiPeripheral.readValueForCharacteristic(asobiCharacteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("error:\(error)")
            return
        }
        let twitterId = (NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding))! as String
        let user = User(id: twitterId)
        if  user.containsUsers(users) == false {
            users.addObject(user)
            asobiPeripherals.append(asobiPeripheral)
            fetchHostUserData(user)
        }
    }
    
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func fetchHostUserData(user: User) {
        let client = Twitter.sharedInstance().APIClient
        client.loadUserWithID(user.id, completion: { (obj, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                do {
                    let iconUrl = NSURL(string: (obj?.profileImageURL)!)
                    let iconData = try NSData(contentsOfURL: iconUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    let image = UIImage(data: iconData)
                    user.name = (obj?.name)!
                    user.screenName = (obj?.screenName)!
                    user.image = image
                    self.tableView.reloadData()
                } catch {
                    print("error")
                }
            }
        })
    }
    
    //TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell") as! TwitterUserTableViewCell
        let user = users[indexPath.row] as! User
        cell.imageView?.image = user.image
        cell.nameLabel.text = user.screenName
        cell.idLabel.text = user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row] as! User
        SVProgressHUD.showWithStatus("\(user.screenName)さんに\nリクエスト中")
        //tableView.userInteractionEnabled = false
        progressCoverView.hidden = false
    }
}