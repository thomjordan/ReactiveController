//
//  ConnectionModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class ConnectionModel : Codable {
    
    var targetID        : Int
    
    var targetInputNum  : Int
    
    var sourceID        : Int
    
    var sourceOutputNum : Int
    
    var codeScript : CodeScriptModel = CodeScriptModel()
    
    var isSelected : Bool = false
    
 //   weak var reactor : ConnectionReactor?
    
//    var codeScript : CodeScriptModel! = CodeScriptModel()  // try to refactor these out to a different bounded context 
//    var cableParameters : [ParameterProperty] = []
    
    
    init( targetID: Int, targetInputNum: Int, sourceID: Int, sourceOutputNum: Int ) {
        
        self.targetID        = targetID
        
        self.targetInputNum  = targetInputNum
        
        self.sourceID        = sourceID
        
        self.sourceOutputNum = sourceOutputNum
    }
    
    enum CodingKeys : String, CodingKey {
        case targetIDnum
        case targetInput
        case sourceIDnum
        case sourceOutput
        case selected
        case code
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.targetID = try vals.decode( Int.self, forKey: .targetIDnum )
        self.targetInputNum = try vals.decode( Int.self, forKey: .targetInput )
        self.sourceID = try vals.decode( Int.self, forKey: .sourceIDnum )
        self.sourceOutputNum = try vals.decode( Int.self, forKey: .sourceOutput )
        self.isSelected = try vals.decode( Bool.self, forKey: .selected )
        self.codeScript = try vals.decode( CodeScriptModel.self, forKey: .code )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( targetID, forKey: .targetIDnum )
        try bin.encode( targetInputNum, forKey: .targetInput )
        try bin.encode( sourceID, forKey: .sourceIDnum )
        try bin.encode( sourceOutputNum, forKey: .sourceOutput )
        try bin.encode( isSelected, forKey: .selected )
        try bin.encode( codeScript, forKey: .code )
    }
    
}

