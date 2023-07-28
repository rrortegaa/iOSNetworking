//
//  VoteModel.swift
//  Kittinder
//
//  Created by L Daniel De San Pedro on 24/07/23.
//

import Foundation

struct VoteModel: Codable {
    let imageID, subID: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case imageID = "image_id"
        case subID = "sub_id"
        case value
    }
}
