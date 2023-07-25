//
//  SignInOutput.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import Foundation

struct SignInOutput: Codable {
    var userName: String
    var password: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case password
    }
}
