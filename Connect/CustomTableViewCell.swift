//
//  CustomTableViewCell.swift
//  Connect
//
//  Created by Chirag Palesha on 12/6/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var lStatus: UILabel!
    @IBOutlet weak var lDescription: UILabel!
    @IBOutlet weak var lCategory: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

