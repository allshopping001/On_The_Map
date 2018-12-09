//
//  OTMTableViewCell.swift
//  OnTheMap
//
//  Created by macos on 04/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit

class OTMTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var mediaURLLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
