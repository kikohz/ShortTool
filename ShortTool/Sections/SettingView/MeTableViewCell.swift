//
//  MeTableViewCell.swift
//  ShortTool
//
//  Created by Bllgo on 2018/7/6.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit

class MeTableViewCell: UITableViewCell {

    @IBOutlet weak var subTitleLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
