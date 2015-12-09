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
    
    let serviceUUID = CBUUID(string: "632D50CB-9DC0-496C-8E28-19F4E0AA0DBC")
    let characteristicUUID = CBUUID(string: "DF89A6DD-DC47-4C5C-8147-1141C62E1B04")

    var centralManager: CBCentralManager!
    var asobiPeripheral: CBPeripheral!
    var asobiCharacteristic: CBCharacteristic!
    
    var users: NSMutableArray = []

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
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("discover:\(peripheral.description)")
        asobiPeripheral = peripheral
        asobiPeripheral.delegate = self
        centralManager.connectPeripheral(asobiPeripheral, options: nil)
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
        print("didUpdateValue")
        if containsInUsersWithId(twitterId) == false {
            fetchHostUserData(twitterId)
        }
    }
    
    func containsInUsersWithId(id:String) -> Bool {
        for obj in users {
            let user = obj as! User
            if user.id == id { return true }
        }
        return false
    }

 
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func fetchHostUserData(twitterId: String) {
        print("id:\(twitterId)")
        let client = Twitter.sharedInstance().APIClient
        client.loadUserWithID(twitterId, completion: { (user, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                do {
                    let iconUrl = NSURL(string: (user?.profileImageLargeURL)!)
                    print(iconUrl)
                    let iconData = try NSData(contentsOfURL: iconUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    let image = UIImage(data: iconData)
                    UIGraphicsBeginImageContext(CGSize(width: 60, height: 60))
                    image?.drawInRect(CGRect(x: 0, y: 0, width: 60, height: 60))
                    let iconImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    let user = User(id: (user?.userID)!, name: (user?.name)!, screenName: (user?.screenName)!, image: iconImage)
                    self.users.addObject(user)
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
        print(user.image.size)
        cell.nameLabel.text = user.screenName
        cell.idLabel.text = user.name
        return cell
    }
}