//
//  TableViewCell.swift
//  weatherApp
//
//  Created by Colon, Joel on 8/9/17.
//  Copyright © 2017 Intern. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var typeCell: UIView!
    @IBOutlet weak var valueCell: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
