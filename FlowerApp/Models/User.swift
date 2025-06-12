//
//  User.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation

struct User: Codable{
    let id: String
    let email: String
    let joined: TimeInterval
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "User", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert user to dictionary"])
        }
        return dictionary
    }
}
