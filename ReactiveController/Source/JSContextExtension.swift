//
//  JSContextExtension.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/30/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import JavaScriptCore


extension JSContext {
    
    func jsValueForProperty(_ prop: String) -> JSValue?  {
        
        guard let globalObj = self.globalObject else { return nil }
        
        guard globalObj.hasProperty(prop) else { return nil }
        
        let result = globalObj.forProperty(prop)
        
        return result
    }
    
    func stringValueForProperty(_ prop: String) -> String? {
        
        guard let result = jsValueForProperty(prop) else { return nil }
        
        let str = result.toString()
        
        return str
    }
}


