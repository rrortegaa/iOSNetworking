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
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Product
struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Int
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String
    let category: String
    let thumbnail: String
    let images: [String]
}
