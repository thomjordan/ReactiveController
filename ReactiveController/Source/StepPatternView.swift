//
//  StepPatternView.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 11/13/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

final class StepPatternView: NSView {
    
    let bkcolor           = NSColor( hue: 0.5, saturation: 0.0, brightness: 0.8, alpha: 1.0 )
    let stepsPatternColor = NSColor( hue: 0.576,  saturation: 0.75,  brightness: 0.83,  alpha: 1.0 )
    let selectedStepColor = Colors.glowstickGreen
    
    struct Design {
        var pathmaker   : StepPatternViewArchitect
        var startOffset : NSPoint
        var stepBoxSize : NSSize
        var padding     : NSSize
        var mainColor   : NSColor
    }
    
    var design           : Design!
    var stepsPatternPath : NSBezierPath = NSBezierPath()
    var selectedStepPath : NSBezierPath = NSBezierPath()
    
    
    init(frame: NSRect, initialSteps: [Int], selectedStep: Int = 0) {
        
        super.init(frame: frame)
        
        stepsPatternPath = NSBezierPath()
        selectedStepPath = NSBezierPath()
        
        // design parameters
        self.design = Design(
            pathmaker   : StepPatternViewArchitect(),
            startOffset : NSPoint(x:4, y:-1),
            stepBoxSize : NSSize(width:15, height:5),
            padding     : NSSize(width:0, height:0),
            mainColor   : NSColor( hue: 0.733,  saturation: 1.0,  brightness: 1.000,  alpha: 1.0 )
        )
        
        updateDesign( initialSteps, selectedStep )
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    func updateDesign(_ stepPattern: [Int], _ selectedStep: Int = 0) {
        
        printLog("StepPatternView:updateDesign(steps) called successfully with steps = \(stepPattern)")
        
        let resultingPaths =
            design.pathmaker.makeShapePath(
                steps   : stepPattern,
                index   : selectedStep,
                offset  : design.startOffset,
                size    : design.stepBoxSize,
                padding : design.padding
        )
        
        stepsPatternPath = resultingPaths.0
        selectedStepPath = resultingPaths.1
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSBezierPath.defaultLineJoinStyle = NSBezierPath.LineJoinStyle.miterLineJoinStyle
        
        bkcolor.set() // set background color
        NSBezierPath.fill(dirtyRect)
        
      //  NSColor.black.set()
      //  stepsPatternPath.lineWidth = 1.0
      //  stepsPatternPath.stroke()
        
        stepsPatternColor.set()
        stepsPatternPath.fill()
        
        selectedStepColor.set()
        selectedStepPath.fill()
    }
    
//    func updateView() {
//        DispatchQueue.main.async {
//            self.needsDisplay = true
//        }
//    }
}


class StepPatternViewArchitect {
    
    func makeShapePath(steps:[Int], index: Int, offset: NSPoint, size:NSSize, padding:NSSize) -> (NSBezierPath, NSBezierPath) {
        
        let numsteps    = steps.count
        
        let stepBoxes   = NSBezierPath()
        let currStepBox = NSBezierPath()
        var shapePoints:[NSPoint]

        for i in 0..<numsteps {
            
            shapePoints = computeNewPointsForStep(i, stepVal: steps[i]+1, offset: offset, size: size, pad: padding)
            
            addStepBoxToPath(stepBoxes, shapeOutline: shapePoints)
            
            if i == index%numsteps {
                // Within the fresh new path named 'currStepBox',
                // we add a single box only, denoting the currently selected step.
                addStepBoxToPath(currStepBox, shapeOutline: shapePoints)
            }
        }
        
        let results = (stepBoxes, currStepBox)
        
        return results
    }
    
    
    fileprivate func computeNewPointsForStep(_ stepNum: Int, stepVal:Int, offset:NSPoint, size: NSSize, pad: NSSize) -> [NSPoint] { // this is the actual "shape pattern"
        let o =  NSPoint(x: 0, y: 0)
        var p = [NSPoint](repeating: o, count: 4)
        p[0] = NSPoint(x: CGFloat(stepNum)*(size.width+pad.width)+offset.x, y:CGFloat(stepVal)*(size.height+pad.height)+offset.y)
        p[1] = NSPoint(x : p[0].x+size.width, y : p[0].y)
        p[2] = NSPoint(x : p[1].x, y : p[1].y+size.height)
        p[3] = NSPoint(x : p[0].x, y : p[2].y)
        let result = p
        return result
    }
    
    fileprivate func addStepBoxToPath(_ bp: NSBezierPath, shapeOutline: [NSPoint]) {
        bp.move(to: shapeOutline[0])
        bp.line(to: shapeOutline[1])
        bp.line(to: shapeOutline[2])
        bp.line(to: shapeOutline[3])
        bp.line(to: shapeOutline[0])
    }
}

class BarBeatShaderView : NSView {
    
    override init(frame: NSRect)   { super.init(frame: frame) }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        BarBeatShader.drawShadedDownBeats(frame: frame, size: frame.size, alphaA: 0.618, alphaB: 0.382)
    }
}

/*
work on Functional API with currying to shadow existing parameter values on the fly
ex:  pointA >> x+=5 >> pointB >> reflect >> pointC   or something like that)
then apply these ideas to hierarchical music representation practices
(e.g. geometric data structures, functional abstraction and application, term-rewriting)
*/

