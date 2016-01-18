//
//  GameStartViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class GameStartViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        setupScrollSubViews()
    }
    
    func setupScrollSubViews() {
        let margin:CGFloat = 10
        let viewWidth = scrollView.bounds.size.width - margin*2
        let viewHeight = scrollView.bounds.size.height - margin*2
        var viewX:CGFloat = margin
        let viewY:CGFloat = margin
        let subViewCount = 4
        for var i = 0; i < subViewCount; i++ {
            let imageView = UIImageView(image: UIImage(named: "tutorial\(i+1).png"))
            imageView.frame = CGRect(x: viewX, y: viewY, width: viewWidth, height: viewHeight)
            viewX += viewWidth+margin*2
            self.scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSize(width: viewX-margin, height: viewHeight)
        pageControl.numberOfPages = subViewCount
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        UIView.animateWithDuration(0.3) { () -> Void in
            self.pageControl.currentPage = Int((scrollView.contentOffset.x+pageWidth/2)/pageWidth)
        }
    }
    
//IBAction
    @IBAction func didTapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPushedCreateRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toCreateRoomVC", sender: self)
    }

    @IBAction func didPushedJoinRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toJoinRoomVC", sender: self)
    }
    @IBAction func didPushLogoutButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
    }
}
