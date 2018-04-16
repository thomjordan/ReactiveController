//
//  CodeScriptModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/6/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


class CodeScriptModel : Codable {
    
    var code : Property<String> = Property("")
    
    var evalCodeTrigger : Property<Bool> = Property(false)
    
    var runnableJSAgent : RunnableJSAgent?
    
    var isEmpty : Bool {
        
        let trimmed = code.value.components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
        
        return trimmed == ""
    }
    
    required init() {}
    
    enum CodingKeys : String, CodingKey {
        case theCode
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        code.value = try vals.decode( String.self, forKey: .theCode)
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( code.value, forKey: .theCode)
    }
    
    
}
