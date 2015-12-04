//
//  TwitterUserTableViewCell.swift
//  TrembleWristband
//
//  Created by minami on 12/2/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit

class TwitterUserTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
