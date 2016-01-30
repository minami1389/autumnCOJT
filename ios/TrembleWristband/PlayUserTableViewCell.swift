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
    @IBOutlet weak var heartLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
