//
//  MeasureHeartBeatViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/18/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class MeasureHeartBeatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func didPushMeasureButton(sender: AnyObject) {
        let heartBeat = 100
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setInteger(heartBeat, forKey: "heartBeat")
        self.performSegueWithIdentifier("measureToPlay", sender: self)
    }

}
