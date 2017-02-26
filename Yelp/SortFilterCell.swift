//
//  SortFilterCell.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/25/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

class SortFilterCell: UITableViewCell {
    
    
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var sortNameLabel: UILabel!
    
    var selectedState: Bool! {
        didSet {
            if selectedState == true {
                selectImage.image = #imageLiteral(resourceName: "ic_select")
            } else {
                selectImage.image = #imageLiteral(resourceName: "ic_unselect")
            }
        }
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
