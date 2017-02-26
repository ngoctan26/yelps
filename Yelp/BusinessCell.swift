//
//  BusinessCell.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/23/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    //View references
    @IBOutlet weak var bussinessImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var business: Business! {
        didSet {
            var urlAsString = ""
            if let imageUrl = business.imageURL {
                urlAsString = imageUrl.absoluteString
            }
            ImageUtils.loadImageFromUrlWithAnimate(imageView: bussinessImage, url: urlAsString)
            nameLabel.text = business.name
            distanceLabel.text = business.distance
            viewCountLabel.text = business.reviewCount?.stringValue
            addressLabel.text = business.address
            var urlAsStringRate = ""
            if let imageUrl = business.ratingImageURL {
                urlAsStringRate = imageUrl.absoluteString
            }
            ImageUtils.loadImageFromUrlWithAnimate(imageView: ratingImage, url: urlAsStringRate)
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
