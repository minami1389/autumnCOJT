//
//  PlayUserTableViewCell.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/25/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class PlayUserTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        heartImageView.image = UIImage.fontAwesomeIconWithName(.Heartbeat, textColor: UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 1.0), size: CGSizeMake(heartImageView.frame.width, heartImageView.frame.height)).imageWithRenderingMode(.AlwaysOriginal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
