//
//  SignInResponse.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import Foundation

struct SignInResponse: Codable {
    let id: Int
    let username, email, firstName, lastName: String
    let gender: String
    let image: String
    let token: String
}
