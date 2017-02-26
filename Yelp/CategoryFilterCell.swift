//
//  CategoryFilterCell.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/25/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

@objc protocol CategoryFilterCellDelegate {
    @objc optional func onCategorySwitchChanged(cell: CategoryFilterCell, cateCode: String, isEnable: Bool)
}

class CategoryFilterCell: UITableViewCell {
    // View references
    @IBOutlet weak var cateNameLabel: UILabel!
    @IBOutlet weak var cateSwitch: UISwitch!
    
    weak var cateDelegate: CategoryFilterCellDelegate!
    var category: [String:String]! {
        didSet {
            cateNameLabel.text = category["name"]
        }
    }
    
    var stateOfCate: Bool! {
        didSet {
            cateSwitch.isOn = stateOfCate
        }
    }
    
    // View actions
    @IBAction func onSwitchChange(_ sender: UISwitch) {
        cateDelegate.onCategorySwitchChanged!(cell: self, cateCode: category["code"]! ,isEnable: sender.isOn)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
