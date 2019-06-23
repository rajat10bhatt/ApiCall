//
//  ProductTableViewCell.swift
//  ApiCall
//
//  Created by Rajat Bhatt on 23/06/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subCategory: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: [String: String]) {
        let color: UIColor = .random()
        self.title.textColor = color
        self.subCategory.textColor = color
        self.price.textColor = color
        self.popularity.textColor = color
        
        if let title = data["title"] {
            self.title.text = title
        } else {
            self.title.text = ""
        }
        
        if let subCategory = data["subcategory"] {
            self.subCategory.text = subCategory
        } else {
            self.subCategory.text = ""
        }
        
        if let price = data["price"] {
            self.price.text = price
        } else {
            self.price.text = ""
        }
        
        if let popularity = data["popularity"] {
            self.popularity.text = popularity
        } else {
            self.popularity.text = ""
        }
    }
}
