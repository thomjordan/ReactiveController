//
//  ConnectionModel.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 2/24/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit



class ConnectionModel : NSObject, NSCoding {
    
    var targetInputNum  : Int!
    
    var sourceID        : Int!
    
    var sourceOutputNum : Int!
    
    var cableParameters : [LabeledAttributeParameter] = []
    
    
    init( targetInputNum: Int, sourceID: Int, sourceOutputNum: Int ) {
        
        super.init()
        
        self.targetInputNum  = targetInputNum
        
        self.sourceID        = sourceID
        
        self.sourceOutputNum = sourceOutputNum
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        self.targetInputNum  = aDecoder.decodeInteger(forKey: "targetInputNum")
        
        self.sourceID        = aDecoder.decodeInteger(forKey: "sourceID")
        
        self.sourceOutputNum = aDecoder.decodeInteger(forKey: "sourceOutputNum")
        
        
        let numAttrs = aDecoder.decodeInteger(forKey: "numberOfCableParameters")
        
        for i in 0..<numAttrs {
            
            let attr = aDecoder.decodeObject( forKey: "attributeParameter_" + String(i) ) as! LabeledAttributeParameter
            
            cableParameters.append( attr )
        }
        
        printLog("A ConnectionModel with targetInputNum \(targetInputNum), sourceID \(sourceID), and sourceOutputNum \(sourceOutputNum) was successfully decoded from the archive.")
    }
    
    
    @objc func encode(with aCoder: NSCoder) {
        
        aCoder.encode(targetInputNum,  forKey: "targetInputNum")
        
        aCoder.encode(sourceID,        forKey: "sourceID")
        
        aCoder.encode(sourceOutputNum, forKey: "sourceOutputNum")
        
        
        let numAttrs : Int = cableParameters.count
        
        aCoder.encode( numAttrs, forKey: "numberOfCableParameters")
        
        for i in 0..<numAttrs {
            
            aCoder.encode( cableParameters[i], forKey: "attributeParameter_" + String(i) )
        }
    }
    
}



