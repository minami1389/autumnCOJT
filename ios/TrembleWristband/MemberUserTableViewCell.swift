//
//  MemberUserTableViewCell.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/16/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class MemberUserTableViewCell: UITableViewCell {
   
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
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
        super.setSelected(selected, animated: true)
    
        if selected {
            containerView.backgroundColor = UIColor(red: 67/255, green: 160/255, blue: 71/255, alpha: 1.0)
            checkBoxImageView.image = UIImage.fontAwesomeIconWithName(.CheckCircleO, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysOriginal)
        } else {
            containerView.backgroundColor = UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1.0)
            checkBoxImageView.image = UIImage.fontAwesomeIconWithName(.CircleO, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysOriginal)
        }

    }
}
