//
//  DealFilterCell.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/25/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

@objc protocol DealFilterCellDelegate {
    @objc optional func onDealFilterChanged(cell: DealFilterCell, isEnable: Bool)
}

class DealFilterCell: UITableViewCell {
    var dealDelegate: DealFilterCellDelegate!
    
    @IBAction func onSwitchChange(_ sender: UISwitch) {
        dealDelegate.onDealFilterChanged!(cell: self, isEnable: sender.isOn)
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
