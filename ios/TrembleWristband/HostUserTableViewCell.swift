//
//  TwitterUserTableViewCell.swift
//  TrembleWristband
//
//  Created by minami on 12/2/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class HostUserTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setShowdow(containerView)
    }

    func setShowdow(view:UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.5
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.darkGrayColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            containerView.backgroundColor = UIColor(red: 255/255, green: 143/255, blue: 0/255, alpha: 1.0)
        } else {
            containerView.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        }

    }

}
