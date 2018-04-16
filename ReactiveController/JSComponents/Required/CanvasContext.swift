//
//  CanvasContext.swift
//  ReactiveController
//
//  Created by Thom Jordan on 10/28/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa 
import DrawableCanvasKit

public protocol CanvasContext : class {
    
    var inView      : ComponentContentView { get }
    var canvas      : DrawableCanvas!      { get set }
    
    var inputTypes  : [String]             { get set }
    var outputTypes : [String]             { get set }
}

extension CanvasContext {
    
    public func processInput(_ innum: Int, _ val: Int) {
        canvas?.processInput(innum, val)
    }

}
