//
//  P4PermutationCubesView.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 11/13/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

import Cocoa

final class P4PermutationCubesView: NSView {
    
    weak var reaktor : StepPatternComponentReactor!
    
    var pathConstructor     : CubeTogglesPathConstructor!
    var thePaths            : ([NSBezierPath], [NSBezierPath], [NSBezierPath])?
    let cubeColorsON        : [String : NSColor] = [ "left" : NSColor( hue: 0.733,  saturation: 0.888,  brightness: 1.000,  alpha: 1.0 ),
                                                     "right": NSColor( hue: 0.733,  saturation: 0.888,  brightness: 0.500,  alpha: 1.0 ),
                                                     "top"  : NSColor( hue: 0.733,  saturation: 0.500,  brightness: 1.000,  alpha: 1.0 ) ]
    let cubeColorsOFF       : [String : NSColor] = [ "left" : NSColor( hue: 0.115,  saturation: 0.888,  brightness: 0.888,  alpha: 1.0 ),
                                                     "right": NSColor( hue: 0.115,  saturation: 0.888,  brightness: 0.500,  alpha: 1.0 ),
                                                     "top"  : NSColor( hue: 0.115,  saturation: 0.500,  brightness: 0.888,  alpha: 1.0 ) ]
    let cubeColorsONfaded   : [String : NSColor] = [ "left" : NSColor( hue: 0.733,  saturation: 0.888,  brightness: 1.000,  alpha: 1.0 ),
                                                     "right": NSColor( hue: 0.733,  saturation: 0.888,  brightness: 0.500,  alpha: 1.0 ),
                                                     "top"  : NSColor( hue: 0.733,  saturation: 0.500,  brightness: 1.000,  alpha: 1.0 ) ]
    let cubeColorsOFFfaded  : [String : NSColor] = [ "left" : NSColor( hue: 0.115,  saturation: 0.888,  brightness: 0.888,  alpha: 1.0 ),
                                                     "right": NSColor( hue: 0.115,  saturation: 0.888,  brightness: 0.500,  alpha: 1.0 ),
                                                     "top"  : NSColor( hue: 0.115,  saturation: 0.500,  brightness: 0.888,  alpha: 1.0 ) ]
    
    let selectionOutlineColor = NSColor( hue: 0.0,  saturation: 0.888,  brightness: 0.15,  alpha: 1.0 )
    
    init( frame: NSRect, size: Double, origin: NSPoint, reaktor: StepPatternComponentReactor ) {
        
        let o = origin 
        let s = CGFloat(size) 
        let p = CGFloat(0.108)
        
        self.reaktor         = reaktor
        self.pathConstructor = CubeTogglesPathConstructor(frame: frame, origin: o, size: s, slope: p)
        self.thePaths        = pathConstructor.getShapePaths()
        
        super.init(frame:frame)
    }
    
    convenience init( frame: NSRect, reaktor: StepPatternComponentReactor ) {
        self.init(frame: frame, size: 17.0, origin: NSPoint(x: 60.0, y: 3.0), reaktor: reaktor )
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    //************** EVENT HANDLING ****************
    
    /*
    override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool { return true }
    
    override func mouseUp(with theEvent: NSEvent) {
        let eventLocation = theEvent.locationInWindow
        let xy            = self.convert(eventLocation, from: nil)
        var paths = thePaths!
        
        // printLog("mouse up detected: x=\(xy.x.native), y=\(xy.y.native)")
        
        for i in 0..<6 {
            if paths.0[i].contains(xy) || paths.1[i].contains(xy) || paths.2[i].contains(xy) {
                reaktor.handleCubeSelection(i) 
                updateView()
                return 
            }
        }
    }
     */
    
    func interpretMouseUp(_ event: MouseUpEvent) {
        
        printLog("P4PermutationCubesView:interpretMouseUp() called.")
        
        let theEvent = event.sender 
        
        let eventLocation = theEvent.locationInWindow
        let xy            = self.convert(eventLocation, from: nil)
        var paths = thePaths!
        
        // printLog("mouse up detected: x=\(xy.x.native), y=\(xy.y.native)")
        
        for i in 0..<6 {
            if paths.0[i].contains(xy) || paths.1[i].contains(xy) || paths.2[i].contains(xy) {
                reaktor.handleCubeSelection(i)
                updateView()
                return
            }
        }
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
    
    //************** VIEW STATE UPDATING ****************
    
    // -- "setNeedsDisplay" is simply called from ViewController, and then logic inside of drawRect() looks to the stored state on
    //      the ViewController to know what to do
    
    //************** AUTO-DRAW UPDATE ****************
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        var lineWidth:CGFloat
        var theCurrentColorset : [String : NSColor]
        var paths             = thePaths!
        let coloringKey:[P4CubeState] = reaktor.cubeStates
        
        NSColor( hue: 0.5, saturation: 0.0, brightness: 0.833, alpha: 1.0 ).set() // set background color
        NSBezierPath.fill(dirtyRect)
        
        for i in 0..<6 {
            
            switch coloringKey[i] {
            case .chyin:
                theCurrentColorset = cubeColorsON
                setDashStyleToPath(paths.0[i])
                setDashStyleToPath(paths.1[i])
                setDashStyleToPath(paths.2[i])
                selectionOutlineColor.set()
                lineWidth = 2.4
            case .chyang:
                theCurrentColorset = cubeColorsOFF
                setDashStyleToPath(paths.0[i])
                setDashStyleToPath(paths.1[i])
                setDashStyleToPath(paths.2[i])
                selectionOutlineColor.set()
                lineWidth = 2.4
            case .yin:
                theCurrentColorset = cubeColorsONfaded
                removeDashStyleFromPath(paths.0[i])
                removeDashStyleFromPath(paths.1[i])
                removeDashStyleFromPath(paths.2[i])
                NSColor.black.set()
                lineWidth = 1.6
            case .yang:
                theCurrentColorset = cubeColorsOFFfaded
                removeDashStyleFromPath(paths.0[i])
                removeDashStyleFromPath(paths.1[i])
                removeDashStyleFromPath(paths.2[i])
                NSColor.black.set()
                lineWidth = 1.6
            default:
                theCurrentColorset = cubeColorsOFFfaded
                removeDashStyleFromPath(paths.0[i])
                removeDashStyleFromPath(paths.1[i])
                removeDashStyleFromPath(paths.2[i])
                NSColor.black.set()
                lineWidth = 1.6
            }
            
            NSBezierPath.defaultLineJoinStyle = NSBezierPath.LineJoinStyle.miterLineJoinStyle
            paths.0[i].lineJoinStyle = NSBezierPath.LineJoinStyle.miterLineJoinStyle 
            
            theCurrentColorset["left"]!.set()
            paths.0[i].fill()
            //NSColor.blackColor().set()
            paths.0[i].lineWidth = lineWidth
            paths.0[i].stroke()
            
            theCurrentColorset["right"]!.set()
            paths.1[i].fill()
            //NSColor.blackColor().set()
            paths.1[i].lineWidth = lineWidth
            paths.1[i].stroke()
            
            theCurrentColorset["top"]!.set()
            paths.2[i].fill()
            //NSColor.blackColor().set()
            paths.2[i].lineWidth = lineWidth
            paths.2[i].stroke()
        }
    }
    
    func setDashStyleToPath(_ bp: NSBezierPath) {
        let lineDash:[CGFloat] = [8, 5]
        bp.setLineDash(lineDash, count: 2, phase: 0.0)
    }
    func removeDashStyleFromPath(_ bp: NSBezierPath) {
        let lineDash:[CGFloat] = [8, 0]
        bp.setLineDash(lineDash, count: 2, phase: 0.0)
    }

}






class CubeTogglesPathConstructor : NSObject {
    
    // arrays to store the results: one path for each facet, stored across three arrays, for each of the three types of cube faces visible from the front of the structure
    var rightFacets  : [NSBezierPath]?
    var leftFacets   : [NSBezierPath]?
    var topFacets    : [NSBezierPath]?
    
    
    init(frame: NSRect, origin: NSPoint, size:CGFloat, slope:CGFloat) {
        
        let nullpt = NSPoint(x: 0, y: 0)
        
        var positions: [String: NSPoint] = ["bottomCenter": nullpt, "bottomRight": nullpt, "bottomLeft": nullpt, "middleRight": nullpt, "middleLeft": nullpt, "topCenter": nullpt]
        
        let theOrigin = origin
        let edgeSize  = size
        var delta     = nullpt
        let theSlope  = slope
        
        super.init()
        
        delta.x = pointOnCircle(nullpt, polar: NSPoint(x: edgeSize, y: theSlope)).x // helps to calculate positions where shapes shall start
        delta.y = pointOnCircle(nullpt, polar: NSPoint(x: edgeSize, y: theSlope)).y
        
        // calculate the positional offsets
        positions["bottomCenter"]  =   theOrigin
        positions["bottomRight" ]  =   NSPoint(  x:  theOrigin.x + delta.x * 2,   y:  theOrigin.y )
        positions["bottomLeft"  ]  =   NSPoint(  x:  theOrigin.x - delta.x * 2,   y:  theOrigin.y )
        positions["middleRight" ]  =   NSPoint(  x:  theOrigin.x + delta.x,       y:  theOrigin.y  +   delta.y + edgeSize )
        positions["middleLeft"  ]  =   NSPoint(  x:  theOrigin.x - delta.x,       y:  theOrigin.y  +   delta.y + edgeSize )
        positions["topCenter"   ]  =   NSPoint(  x:  theOrigin.x,                 y:  theOrigin.y  + ( delta.y + edgeSize ) * 2 )
        
        // initialize path collections
        rightFacets = []
        leftFacets  = []
        topFacets   = []
        
        for _ in 0..<6 {
            rightFacets!.append(NSBezierPath())
            leftFacets!.append(NSBezierPath())
            topFacets!.append(NSBezierPath())
        }
        
        // add facets to paths
        // var toggleCubesOrder = ["topCenter", "middleLeft", "middleRight", "bottomLeft", "bottomCenter", "bottomRight"]
        let toggleCubesOrder = ["bottomLeft", "bottomCenter", "bottomRight", "middleLeft", "topCenter", "middleRight"]
        var shapePoints:[NSPoint]
        
        for (i, keystring) in toggleCubesOrder.enumerated() {
            shapePoints = computeNewPointsForPosition(positions[keystring]!, size: edgeSize, slope: theSlope)
            rightCubeFaceToPath(rightFacets![i], shapeOutline: shapePoints)
            leftCubeFaceToPath(  leftFacets![i], shapeOutline: shapePoints)
            topCubeFaceToPath(    topFacets![i], shapeOutline: shapePoints)
        }
        
    }
    
    // ***************************************************************************************************************************
    
    //  PUBLIC API -- notes: an "origin point" is all that is necessary to determine the placement of a cube
    
    func getShapePaths() -> (leftFacets: [NSBezierPath], rightFacets: [NSBezierPath], topFacets: [NSBezierPath]) {
        let lf = leftFacets!
        let rf = rightFacets!
        let tf = topFacets!
        return (lf, rf, tf)
    }
    /*
    work on Functional API with currying to shadow existing parameter values on the fly
    ex:  pointA >> x+=5 >> pointB >> reflect >> pointC   or something like that)
    then apply these ideas to hierarchical music representation practices
    (e.g. geometric data structures, functional abstraction and application, term-rewriting)
    */
    
    // ***************************************************************************************************************************
    
    func computeNewPointsForPosition(_ position: NSPoint, size: CGFloat, slope: CGFloat) -> [NSPoint] { // this is the actual "shape pattern"
        let o =  NSPoint(x: 0, y: 0)
        var p = [NSPoint](repeating: o, count: 8)
        p[1] = position
        p[2] = NSPoint(x : p[1].x, y : p[1].y+size)
        p[3] = pointOnCircle(p[2], polar: NSPoint(x: size, y: slope))
        p[4] = NSPoint(x : p[3].x, y : p[3].y-size)
        p[5] = pointOnCircle(p[1], polar: NSPoint(x: size, y: 1.0-slope))
        p[6] = NSPoint(x : p[5].x, y : p[5].y+size)
        p[7] = pointOnCircle(p[6], polar: NSPoint(x: size, y: slope))
        return p
    }
    
    
    func rightCubeFaceToPath(_ bp: NSBezierPath, shapeOutline: [NSPoint]) {
        bp.move(to: shapeOutline[1])
        bp.line(to: shapeOutline[2])
        bp.line(to: shapeOutline[3])
        bp.line(to: shapeOutline[4])
        bp.line(to: shapeOutline[1])
    }
    
    func leftCubeFaceToPath(_ bp: NSBezierPath, shapeOutline: [NSPoint]) {
        bp.move(to: shapeOutline[1])
        bp.line(to: shapeOutline[5])
        bp.line(to: shapeOutline[6])
        bp.line(to: shapeOutline[2])
        bp.line(to: shapeOutline[1])
    }
    
    func topCubeFaceToPath(_ bp: NSBezierPath, shapeOutline: [NSPoint]) {
        bp.move(to: shapeOutline[2])
        bp.move(to: shapeOutline[6])
        bp.line(to: shapeOutline[7])
        bp.line(to: shapeOutline[3])
        bp.line(to: shapeOutline[2])
    }

}







