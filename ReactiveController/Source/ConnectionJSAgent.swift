//
//  ConnectionJSAgent.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/30/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


class ConnectionJSAgent : GeneralJSAgent {
    
    var task : SignalTaskType!
    
    init(_ cModel: CodeScriptModel, task: SignalTaskType) {
        
        super.init(cModel)
        
        self.task = task
        
        insertDefaultCode(for: task.attrParams)
        
        runScript() 
    }
    
    override func runScript() {
        
        updateParameterPropertyValuesFromJSContext(for: task.attrParams)
        
        super.runScript()
    }
    
}


