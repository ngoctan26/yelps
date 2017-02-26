//
//  DistanceFilterCell.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/25/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

class DistanceFilterCell: UITableViewCell {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSelectImage: UIImageView!
    
    var selectedState: Bool! {
        didSet {
            if selectedState == true {
                distanceSelectImage.image = #imageLiteral(resourceName: "ic_select")
            } else {
                distanceSelectImage.image = #imageLiteral(resourceName: "ic_unselect")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
