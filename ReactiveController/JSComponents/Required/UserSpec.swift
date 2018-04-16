//
//  UserSpec.swift
//  ReactiveController
//
//  Created by Thom Jordan on 3/22/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation


public struct UserSpec: Decodable, JSONConstructible {
    let name: String?
    let inputs: [String]?
    let outputs: [String]?
    let frame: [Int]?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case inputs
        case outputs
        case frame
    }
}


