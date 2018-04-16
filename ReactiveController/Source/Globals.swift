//
//  Globals.swift
//  ReactiveControls
//
//  Created by Thom Jordan on 12/16/15.
//  Copyright © 2015 Thom Jordan. All rights reserved.
//

import Cocoa

let workspaceDefaultFrame = NSMakeRect(0, 0, 2000, 2000)
//let workspaceDefaultFrame = NSMakeRect(0, 0, 2000, 1250)

let mainBGColor   = NSColor(calibratedRed:0.22953125, green:0.210, blue:0.25296875, alpha:1.0)
let mainBGcolorCG = CGColor(red: 0.22953125, green: 0.210, blue: 0.25296875, alpha: 1.0)

let componentBGColor  = NSColor(calibratedRed: 0.155, green: 0.166, blue: 0.214, alpha: 1)

let tvEmptyBGColorLight = NSColor(calibratedRed: 0.735, green: 0.746, blue: 0.834, alpha: 1)

let tvEmptyRowBGColorA = NSColor(calibratedRed: 0.435, green: 0.446, blue: 0.494, alpha: 1)
let tvEmptyRowBGColorB = NSColor(calibratedRed: 0.335, green: 0.346, blue: 0.394, alpha: 1)

let menuCellBGColorA  = NSColor(calibratedRed: 0.235, green: 0.246, blue: 0.294, alpha: 1)
let menuCellBGColorB  = NSColor(calibratedRed: 0.215, green: 0.226, blue: 0.274, alpha: 1)
let menuCellBGColorC  = NSColor(calibratedRed: 0.195, green: 0.206, blue: 0.254, alpha: 1)
let menuCellBGColorD  = NSColor(calibratedRed: 0.175, green: 0.186, blue: 0.234, alpha: 1)

let textCellBGColor   = NSColor(calibratedRed: 0.72, green: 0.73, blue: 0.737, alpha: 1.0)
let textCellTextColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.75, alpha: 1)

struct Colors {
    
    static let uiComponentInterfaceBackground = NSColor(calibratedRed: 0.155, green: 0.166, blue: 0.214, alpha: 1)
    static let selectedControl   = NSColor(calibratedRed: 164/255.0, green: 205/255.0, blue: 1, alpha: 1)
    
    static let goldenrodBrown    = NSColor(calibratedRed: 143/255.0, green: 116/255.0, blue:  63/255.0, alpha: 1.0) // 143, 116,  63
    static let goldenSunYellow   = NSColor(calibratedRed: 233/255.0, green: 189/255.0, blue:  21/255.0, alpha: 1.0) // 233, 189,  21
    static let trafficLightGreen = NSColor(calibratedRed:  39/255.0, green: 232/255.0, blue:  51/255.0, alpha: 1.0) //  39, 232,  51
    static let glowstickGreen    = NSColor(calibratedRed: 147/255.0, green: 239/255.0, blue:  97/255.0, alpha: 1.0) // 147, 239,  97
    static let airForceBlue      = NSColor(calibratedRed:  61/255.0, green:  82/255.0, blue: 200/255.0, alpha: 1.0) //  61,  82, 200
    static let atlanticBlue      = NSColor(calibratedRed:  74/255.0, green: 152/255.0, blue: 237/255.0, alpha: 1.0) //  74, 152, 237
    static let atlanticSkyBlue   = NSColor(calibratedRed: 130/255.0, green: 190/255.0, blue: 245/255.0, alpha: 1.0) // 130, 190, 245
    static let goodGirlViolet    = NSColor(calibratedRed: 123/255.0, green:  92/255.0, blue: 229/255.0, alpha: 1.0) // 123,  92, 229
    static let arancioneProfondo = NSColor(calibratedRed: 214/255.0, green: 114/255.0, blue:  19/255.0, alpha: 1.0) // 214, 114,  19
    static let slateBlue         = NSColor(calibratedRed:  16/255.0, green:  98/255.0, blue: 122/255.0, alpha: 1.0) //  16,  98, 122
    
}



let phi1:CGFloat = 1.6180339888
let phi2:CGFloat = 0.6180339888
let phi3:CGFloat = 0.3819660112
let phi4:CGFloat = 1.3819660112


// Utils

public var verbose : Bool = false 

public func printLine<T>(_ x: T) {Swift.print(x)} // Global print function to use from NSView

public func printLog(_ s: String) { verbose ? printLine(s) : () }

// func printToLog<T>(s: T) { printLine(s) }

public func absValOp(_ inval: Int, _ op: (Int) -> Int) -> Int {
    
    let sign = inval < 0 ? (-1) : 1
    
    return op( abs(inval) ) * sign
    
}


public func absValOp(_ inval: CGFloat, _ op: (CGFloat) -> CGFloat) -> CGFloat {
    
    let sign = inval < CGFloat(0) ? CGFloat(-1) : CGFloat(1)
    
    return op( CGFloat(abs(inval)) ) * sign
    
}


public func getValidFont(_ size: CGFloat = 10) -> NSFont {
    
    if let _ = NSFont(name:"Helvetica Neue Bold", size: size) {  //  "Avenir-Heavy"
        
        return NSFont(name:"Helvetica Neue Bold", size: size)!
        
    } else {
        
        return NSFont(name:"Arial", size: size)!
    }
}

// must be used within an operating graphics context

public func drawGradientFrom(_ aColor: NSColor, to bColor: NSColor, inRect bounds: NSRect) {
    
    let gradient = NSGradient(starting: aColor, ending: bColor)!
    
    let activeAreaPath = NSBezierPath(rect: bounds)
    gradient.draw(in: activeAreaPath, angle: -90)
}


public func delay(_ delay:Int, closure:@escaping ()->()) {   // delay in ms 
    let when = DispatchTime.now() + (Double(delay) / 1000.0)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    //DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}



