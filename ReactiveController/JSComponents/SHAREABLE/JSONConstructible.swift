//
//  JSONConstructible.swift
//  ReactiveController
//
//  Created by Thom Jordan on 3/22/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation

public protocol JSONConstructible {
    static func fromJSON(at url: URL) -> Self?
}

public extension JSONConstructible where Self : Decodable {
    
    static func fromJSON(at url: URL) -> Self? {
        
        let json = url.contents.filter { $0.isFileType(".json") }
        
        guard let jsonURL = json.first,
              let str     = try? String(contentsOf: jsonURL),
              let data    = str.data(using: .utf8) else {
                print("\(Self.self).fromJSON(at url: \(url)) found ERROR.")
                return nil
            }
        
        let decoder = JSONDecoder()
        
        let result : Self? = try? decoder.decode(Self.self, from: data)
        
        return result
    }
    
}
