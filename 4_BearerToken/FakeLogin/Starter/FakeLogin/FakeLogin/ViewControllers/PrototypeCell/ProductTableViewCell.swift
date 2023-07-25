//
//  ProductTableViewCell.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet private var productName: UILabel?
    @IBOutlet private var brandName: UILabel?
    @IBOutlet private var productDescription: UILabel?
    @IBOutlet private var category: UILabel?

    func set(product: Product) {
        productName?.text = product.title
        brandName?.text = product.brand
        productDescription?.text = product.description
        category?.text = product.category
    }
}
