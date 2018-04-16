//
//  WorkpageGridView.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/13/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import QuartzCore
import AppKit


// ---------------------------------------------
//  MARK: - WorkpageGridView
// ---------------------------------------------


class WorkpageGridView : NSView {
    
    var gridSize    : CGFloat = 0
    
    var gridState   : Bool = true {
        
        didSet { updateView() }
    }
    
    var clearPath   : NSBezierPath!

    
    override var isFlipped:Bool {
        
        get { return false }
    }
    
    
    
    init(frame: NSRect, gridSize:CGFloat = 10) {
        
        super.init(frame: frame)
        
        self.gridSize    = gridSize
        
        self.clearPath   = NSBezierPath(rect: self.bounds)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        NSGraphicsContext.saveGraphicsState()
        
        NSColor.clear.set()
        
        clearPath.fill()
        
        NSGraphicsContext.restoreGraphicsState()
        
        drawGridBackground(self.bounds, gridSize:self.gridSize, gridState:self.gridState)
        
    }

    
    func drawGridBackground(_ theRect: NSRect, gridSize:CGFloat = 10, gridState:Bool = true) {
        
        guard gridState else { return }
        
        let rect = NSMakeRect(0,0,theRect.width,theRect.height)
        
        let path      = NSBezierPath()
        
        let thickPath = NSBezierPath()
        
        let lastVerticalLineNumber   = Int(floor(NSMaxX(rect) / (gridSize*1.0)))+1
        
        let lastHorizontalLineNumber = Int(floor(NSMaxY(rect) / (gridSize*1.0)))
        
        
        for lineNum in Int(ceil(NSMinX(rect)))..<lastVerticalLineNumber {
            
            path.move(to: NSMakePoint(CGFloat(lineNum)*gridSize, NSMinY(rect)))
            
            path.line(to: NSMakePoint(CGFloat(lineNum)*gridSize, NSMaxY(rect)))
        }
        
        for lineNum in Int(ceil(NSMinY(rect)))..<lastHorizontalLineNumber {
            
            path.move(to: NSMakePoint(NSMinX(rect), CGFloat(lineNum)*gridSize))
            
            path.line(to: NSMakePoint(NSMaxX(rect), CGFloat(lineNum)*gridSize))
        }
        
        for lineNum in Int(ceil(NSMinX(rect)))..<lastVerticalLineNumber {
            
            if lineNum % 2 == 0 {
                
                thickPath.move(to: NSMakePoint(CGFloat(lineNum)*gridSize, NSMinY(rect)))
                
                thickPath.line(to: NSMakePoint(CGFloat(lineNum)*gridSize, NSMaxY(rect)))
            }
        }
        
        for lineNum in Int(ceil(NSMinY(rect)))..<lastHorizontalLineNumber {
            
            if lineNum % 2 == 0 {
                
                thickPath.move(to: NSMakePoint(NSMinX(rect), CGFloat(lineNum)*gridSize))
                
                thickPath.line(to: NSMakePoint(NSMaxX(rect), CGFloat(lineNum)*gridSize))
            }
        }
        
        
        let pattern: [CGFloat] = [gridSize*0.618, gridSize*0.382]
        
        NSGraphicsContext.saveGraphicsState()
        
        NSColor.gray.set()
        
        path.lineWidth = 0.382
        
        thickPath.lineWidth = 0.382
        
        thickPath.setLineDash(pattern, count: 2, phase: gridSize*0.309)
        
        path.stroke()
        
        thickPath.stroke()
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
    
}

