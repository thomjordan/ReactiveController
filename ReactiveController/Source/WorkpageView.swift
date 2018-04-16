//
//  WorkpageView.swift
//  ReactiveControls
//
//  Created by Thom Jordan on 11/16/15.
//  Copyright © 2015 Thom Jordan. All rights reserved.
//


import Cocoa
import QuartzCore
import AppKit
import SpriteKit
import ReactiveKit
import Bond 


class WorkpageView : NSView, Selectable {

    var isSelected : Bool = false 
    
    weak var reactor : WorkpageReactor?  // try to refactor out
    
    var backgroundPath : NSBezierPath = NSBezierPath(rect: workspaceDefaultFrame)
    
    var connectionPathInProgress = NSBezierPath()
    
    var connectionColor = NSColor.gray
    
    let gridView = WorkpageGridView(frame:NSMakeRect(0,0, workspaceDefaultFrame.width, workspaceDefaultFrame.height), gridSize:24)
    
    var bgColor : NSColor = NSColor(calibratedRed:0.22953125, green:0.210, blue:0.25296875, alpha:1.0)
    
    var gridState : Bool = true {
        
        didSet { gridView.gridState = gridState }
    }
    
    override var isFlipped:Bool {
        
        get { return false }
    }
    
    
    override init(frame: NSRect) {
        
        // printLog("WorkpageView: init(frame) called. <-----")
    
        super.init(frame: frame)
        
        self.gridState = true
        
        self.addSubview(gridView)
        
        updateView() 
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        drawBackgroundColor()
        
        drawExistingConnections()
        
        drawConnectionInProgress()
    }
    
    
//    override func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.gridView.needsDisplay = true
//            self?.needsDisplay = true
//        }
//    }
    
    
    func drawBackgroundColor() {
        
        NSGraphicsContext.saveGraphicsState()
        
        self.bgColor.set()
        
        self.backgroundPath.fill()
        
        NSGraphicsContext.restoreGraphicsState()
        
    }
 
    
    func drawConnectionInProgress() {
        
        guard let startPoint = reactor?.clickedOutputPointLocation else { return }
        
        guard let currentEnd = reactor?.currentLineDragEndLocation else { return }
        
        NSGraphicsContext.saveGraphicsState()
        
        connectionPathInProgress.removeAllPoints()
        
        connectionPathInProgress.move(to: startPoint)
        
        connectionPathInProgress.line(to: currentEnd)
        
        connectionPathInProgress.lineWidth = 2.5
        
        connectionColor.set()
        
        connectionPathInProgress.stroke()
        
        NSGraphicsContext.restoreGraphicsState()
    }
     
    
    func changeCurrentConnectionToSelectionColor() {
        
        connectionColor = NSColor.yellow
        
        updateView()
    }
    
    func changeCurrentConnectionToStandardColor() {
        
        connectionColor = NSColor.gray
        
        updateView()
    }
    
    
    func drawExistingConnections() {
        
        guard let theCurrentConnections = reactor?.currentConnections else { return }
        
        for connection in theCurrentConnections {
            
            NSGraphicsContext.saveGraphicsState()
            
            connection.cordPath.removeAllPoints()
            
            connection.cordRect.removeAllPoints()
            
            connection.cordRegion.removeAllPoints()
            
            guard let sourceOrigin = connection.sourceUnit?.compView?.frame.origin else {
                NSGraphicsContext.restoreGraphicsState()
                return }
            
            guard let sourceOffset = connection.sourceOutput?.vc?.center else {
                NSGraphicsContext.restoreGraphicsState()
                return }
            
            guard let targetOrigin = connection.targetUnit?.compView?.frame.origin else {
                NSGraphicsContext.restoreGraphicsState()
                return }
            
            guard let targetOffset = connection.targetInput?.vc?.center else {
                NSGraphicsContext.restoreGraphicsState()
                return }
            
            connection.cordPath.move( to: NSMakePoint( sourceOrigin.x + sourceOffset.x,  sourceOrigin.y + sourceOffset.y ) )
            
            connection.cordPath.line( to: NSMakePoint( targetOrigin.x+targetOffset.x,  targetOrigin.y+targetOffset.y ) )
            
            connection.cordPath.lineWidth = 2.5
            
            connection.isSelected ? NSColor.yellow.set() : NSColor.lightGray.set()
            
            connection.cordPath.stroke()
            
            
            // Calculate the equation for the connection line and two perpendicular lines of a short constant length,
            
            // intersecting at source point and target point, resspectively.
            
            // Then use the start and end points of each short perpendicular line segment as the four corners of the rotated rect.
            
            
            let srcPt = NSMakePoint( sourceOrigin.x + sourceOffset.x,  sourceOrigin.y + sourceOffset.y )
            
            let trgPt = NSMakePoint( targetOrigin.x+targetOffset.x,  targetOrigin.y+targetOffset.y )
            
            
            let lineRect1 = createRegionForLineWithRect(srcPt: srcPt, trgPt: trgPt, width: 2.0)
            
            let lineRect2 = createRegionForLineWithRect(srcPt: srcPt, trgPt: trgPt, width: 7.5)
            
            connection.cordRect.append(lineRect1)
            
            connection.cordRect.lineWidth = 1
            
            connection.isSelected ? NSColor.yellow.set() : NSColor.lightGray.set()
            
            connection.cordRect.stroke()
            
            connection.cordRect.fill()
            
            
            connection.cordRegion.append(lineRect2)
            
            connection.cordRect.lineWidth = 1
            
            NSColor.clear.set()
            
            connection.cordRegion.stroke()
            
            connection.cordRegion.fill()
            
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    
    
    // refactor into external object...
    
    func createRegionForLineWithRect(srcPt: NSPoint, trgPt: NSPoint, width: CGFloat) -> NSBezierPath {
        
        let paths = makeEndWidths(p1: srcPt, p2: trgPt, width: width)
        
        let pathRect = NSBezierPath()
        
        var points : [NSPoint] = [NSPoint(), NSPoint()]
        
        let _ = paths.0.element(at: 0, associatedPoints: &points )
        
        pathRect.move( to: points[0] )
        
        let _ = paths.0.element(at: 1, associatedPoints: &points )
        
        pathRect.line( to: points[0] )
        
        let _ = paths.1.element(at: 0, associatedPoints: &points )
        
        pathRect.line( to: points[0] )
        
        let _ = paths.1.element(at: 1, associatedPoints: &points )
        
        pathRect.line( to: points[0] )
        
        pathRect.close()
        
        return pathRect
    }
    
    
    
    func calcAngle(_ p1: NSPoint, _ p2: NSPoint) -> CGFloat {
        
        let dy = Double(p2.y - p1.y)
        
        let dx = Double(p2.x - p1.x)
        
        return CGFloat( atan2( dy, dx ))
    }
    
    func calcOrthogonalAngles(_ theta: CGFloat) -> (CGFloat, CGFloat) {
        
        let a1 = Double(theta) + 3.0 * .pi / 4.0
        
        let a2 = Double(theta) + 5.0 * .pi / 4.0
        
        return ( CGFloat( a1.truncatingRemainder(dividingBy: .pi)*1.0 ), CGFloat( a2.truncatingRemainder(dividingBy: .pi)*1.0 ))
    }
    
    func rotationTransform(_ angle: CGFloat, vertex: NSPoint) -> AffineTransform {
        
        var transform = AffineTransform.identity
        
        transform.translate(x: vertex.x, y: vertex.y)
        
        transform.rotate(byRadians: angle)
        
        transform.translate(x: -vertex.x, y: -vertex.y)
        
        return transform
    }
    
    func makeEndWidths(p1: NSPoint, p2: NSPoint, width: CGFloat) -> (NSBezierPath, NSBezierPath) {
        
        let (_, theta2) = calcOrthogonalAngles( calcAngle(p1, p2) )
        
        let l1 = NSBezierPath()
        
        let l2 = NSBezierPath()
        
        l1.move( to: NSMakePoint(p1.x-width, p1.y))
        
        l1.line( to: NSMakePoint(p1.x+width, p1.y))
        
        l2.move( to: NSMakePoint(p2.x+width, p2.y))
        
        l2.line( to: NSMakePoint(p2.x-width, p2.y))
        
        let rot1 = rotationTransform(theta2, vertex: p1)
        
        let rot2 = rotationTransform(theta2, vertex: p2)
        
        l1.transform(using: rot1)
        
        l2.transform(using: rot2)
        
        return ( l1, l2 )
        
    }

}


