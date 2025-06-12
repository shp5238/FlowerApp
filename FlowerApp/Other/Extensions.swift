//
//  Extensions.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation

extension Encodable{
    //assumes app has an acceptable fallback and can safely handle
    //otherwise, app needs dict for critical data and needs to know if somehting failed
    //throw NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)
    func asDictionary() throws -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else{
            return [:]
        }
        do {
            //attempt to deserialize JSON data into a dict
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch{
            return [:]
        }
    }
}
