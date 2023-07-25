//
//  ProductsResponse.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import Foundation

// MARK: - ProductsResponse
struct ProductsResponse: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

// MARK: - Product
struct Product: Codable {
    let id: Int
    let title, description: String
    let price: Int
    let discountPercentage, rating: Double
    let stock: Int
    let brand, category: String
    let thumbnail: String
    let images: [String]
}
