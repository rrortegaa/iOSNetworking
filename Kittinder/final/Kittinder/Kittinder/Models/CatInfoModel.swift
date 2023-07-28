//
//  CatInfoModel.swift
//  Kittinder
//
//  Created by L Daniel De San Pedro on 24/07/23.
//

import Foundation

struct CatInfoModel: Codable {
    let breeds: [BreedModel]?
    let id: String
    let url: String
    let width, height: Int
}
