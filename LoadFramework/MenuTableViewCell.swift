//
//  MenuTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez on 1/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var leftIconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var rightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
