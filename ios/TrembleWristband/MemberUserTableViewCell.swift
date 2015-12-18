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
    @IBOutlet weak var acceptStateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        if selected {
            self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
            acceptStateLabel.text = "承認"
        } else {
            self.backgroundColor = UIColor.whiteColor()
            acceptStateLabel.text = "承認待ち"
        }

    }
}
