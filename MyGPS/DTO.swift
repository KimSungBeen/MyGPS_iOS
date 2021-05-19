//
//  UserDTO.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/04/28.
//

import Foundation

struct LocationDataRequestBody: Codable {
    let resultMessage: String
    let resultCode: String
    let locationData: [LocationData]
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let date: String
}

struct LoginRequestBody: Codable {
    let resultMessage: String
    let resultCode: String
    let user: User?
    
    /*
    enum CodingKeys: String, CodingKey {
        case resultMessage, resultCode, user
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        resultMessage = try values.decode(String.self, forKey: .resultMessage)
        resultCode = try values.decode(String.self, forKey: .resultCode)
        user = try values.decode([User].self, forKey: .user) ?? nil
    }
    */
    
}

struct User: Codable {
    let id: String
    let sns: String
    let signUpDate: String
}

struct SignUpRequestBody: Codable {
    let resultMessage: String
    let resultCode: String
}
