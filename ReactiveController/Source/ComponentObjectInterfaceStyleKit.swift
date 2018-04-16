//
//  ComponentObjectInterfaceStyleKit.swift
//  ReactiveControls
//
//  Created by ThomJordan on 6/19/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import Cocoa

public class ComponentObjectInterfaceStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc dynamic public class func drawObjectInterface(theSizeFrame: NSSize = NSSize(width: 144, height: 144)) {
        //// Color Declarations
        let color = NSColor(red: 0.205, green: 0.222, blue: 0.277, alpha: 1)
        let shadow2Color = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        let edgeGrey = NSColor(red: 0.372, green: 0.372, blue: 0.372, alpha: 1)
        
        //// Shadow Declarations
        let shadow2 = NSShadow()
        shadow2.shadowColor = shadow2Color.withAlphaComponent(0.35 * shadow2Color.alphaComponent)
        shadow2.shadowOffset = NSSize(width: 0, height: 0)
        shadow2.shadowBlurRadius = 0
        
        //// objectBody Drawing
        let objectBodyPath = NSBezierPath(roundedRect: NSRect(x: 0.5, y: -0.5, width: theSizeFrame.width, height: theSizeFrame.height), xRadius: 3, yRadius: 3)
        color.setFill()
        objectBodyPath.fill()
        NSGraphicsContext.saveGraphicsState()
        shadow2.set()
        edgeGrey.setStroke()
        objectBodyPath.lineWidth = 1
        objectBodyPath.stroke()
        NSGraphicsContext.restoreGraphicsState()
    }
    
}
