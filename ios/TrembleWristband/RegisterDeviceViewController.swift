//
//  RegisterDeviceViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 2/1/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import UIKit
import AVFoundation


class RegisterDeviceViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var qrCodeView: UIView!
    
    var videoLayer:AVCaptureVideoPreviewLayer?
    var session:AVCaptureSession?
    var captureDevice:AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupQRReader()
    }
    
    override func viewDidLayoutSubviews() {
        videoLayer?.frame = self.qrCodeView.frame
    }
    
    func setupQRReader() {
        session = AVCaptureSession()
        guard let session = session else { return }
        for device in AVCaptureDevice.devices() {
            if device.position == AVCaptureDevicePosition.Back {
                guard let device = device as? AVCaptureDevice else { return }
                captureDevice = device
            }
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(videoInput) == true {
                session.addInput(videoInput)
            }
        } catch {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) == true {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let videoLayer = videoLayer else { return }
        videoLayer.frame = self.qrCodeView.frame
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.qrCodeView.layer.addSublayer(videoLayer)
        session.startRunning()
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 { return }
        guard let qrData = (metadataObjects[0] as? AVMetadataMachineReadableCodeObject) else { return }
        let deviceID = qrData.stringValue
        print(deviceID)
        if !deviceID.hasPrefix("FZED") { return }
        APIManager.sharedInstance.fetchDevice(deviceID) { (usedID) -> Void in
            self.session?.stopRunning()
            if usedID {
                self.showUsedDeviceAlert()
            } else {
                APIManager.sharedInstance.createDevice(deviceID, completion: { () -> Void in
                    NSUserDefaults.standardUserDefaults().setObject(deviceID, forKey: kUserDefaultDeviceIDKey)
                    self.showCompleteAlert()
                })
            }
        }
    }
    
    func showUsedDeviceAlert() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertController(title: "失敗", message: "このデバイスはすでに\n他のユーザーに登録されています", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                self.session?.startRunning()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showCompleteAlert() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = UIAlertController(title: "完了", message: "デバイスが登録されました", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                self.performSegueWithIdentifier("registerDeviceToGameStart", sender: self)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        focusTo(touches.first?.locationInView(self.view))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        focusTo(touches.first?.locationInView(self.view))
    }
    
    func focusTo(point: CGPoint?) {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            setPointOfInterest(point)
            device.unlockForConfiguration()
        } catch {}
    }
    
    
    func setPointOfInterest(point: CGPoint?) {
        guard let point = point else { return }
        let viewSize = self.view.bounds.size
        let pointOfInterest = CGPoint(x: point.y/viewSize.height, y: 1.0 - point.x/viewSize.width)
        if captureDevice?.focusPointOfInterestSupported == false { return }
        if captureDevice?.isFocusModeSupported(.AutoFocus) == false { return }
        captureDevice?.focusPointOfInterest = pointOfInterest
        captureDevice?.focusMode = .AutoFocus
    }
}
