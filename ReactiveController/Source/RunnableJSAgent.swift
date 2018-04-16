//
//  RunnableJSAgent.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/30/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import JavaScriptCore


protocol RunnableJSAgent : class {
    
    var errorInfo : JSValue? { get set }
    
    func runScript()
    
    func getErrorMessage() -> String
}
