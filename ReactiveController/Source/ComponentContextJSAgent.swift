//
//  ComponentContextJSAgent.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/8/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


class ComponentContextJSAgent : GeneralJSAgent {
    
    var parameters : [ParameterProperty]!
    
    init(_ cModel: CodeScriptModel, _ params: [ParameterProperty]) {
        
        super.init(cModel)
        
        self.parameters = params
        
        insertDefaultCode(for: self.parameters)
        
        runScript()
    }
    
    override func runScript() {
        
        super.runScript()
        
        updateParameterPropertyValuesFromJSContext(for: self.parameters)
        
        printLog("ComponentContextJSAgent : runScript() ")
    }
    
}



