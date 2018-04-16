//
//  KeyscaleViewHitAreas.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/12/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


final class KeyscaleUIView : ComponentContentView {
    
    weak var kernel : KeyscaleKernelModel!
    
    let hitZones : KeyscaleViewHitZones! = KeyscaleViewHitZones(scale: 1.0)
    
    
    init(_ model: KeyscaleKernelModel) {
        
        super.init(width: 118.0, height: 66.0) 
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let scl : OctaveKeyscaleStepToggles = kernel.scaleSteps
        let hld : OctaveKeyscaleStepToggles = kernel.holdingSteps
        
        KeyscaleStyleKit.drawSizableKeyscaleSensor(kBScale: 1, pc00: scl[0], pc01: scl[1], pc02: scl[2], pc03: scl[3], pc04: scl[4], pc05: scl[5], pc06: scl[6], pc07: scl[7], pc08: scl[8], pc09: scl[9], pc10: scl[10], pc11: scl[11], play0: hld[0], play1: hld[1], play2: hld[2], play3: hld[3], play4: hld[4], play5: hld[5], play6: hld[6], play7: hld[7], play8: hld[8], play9: hld[9], playA: hld[10], playB: hld[11])
    }
    
    
    func interpretMouseUp(with theEvent: NSEvent) {
        
        let flags = theEvent.modifierFlags
        
        guard !flags.contains(.command) else { super.mouseUp(with: theEvent) ; return }
     
        let keyscale = kernel.scaleSteps
        
        let eventLocation = theEvent.locationInWindow
        let xy            = self.convert(eventLocation, from: nil)
        
        // toggles state for clicked area
        
        if      hitZones.pc00keyPath.contains(xy) { keyscale[0]  = keyscale[0]  != true }
        else if hitZones.pc01keyPath.contains(xy) { keyscale[1]  = keyscale[1]  != true }
        else if hitZones.pc02keyPath.contains(xy) { keyscale[2]  = keyscale[2]  != true }
        else if hitZones.pc03keyPath.contains(xy) { keyscale[3]  = keyscale[3]  != true }
        else if hitZones.pc04keyPath.contains(xy) { keyscale[4]  = keyscale[4]  != true }
        else if hitZones.pc05keyPath.contains(xy) { keyscale[5]  = keyscale[5]  != true }
        else if hitZones.pc06keyPath.contains(xy) { keyscale[6]  = keyscale[6]  != true }
        else if hitZones.pc07keyPath.contains(xy) { keyscale[7]  = keyscale[7]  != true }
        else if hitZones.pc08keyPath.contains(xy) { keyscale[8]  = keyscale[8]  != true }
        else if hitZones.pc09keyPath.contains(xy) { keyscale[9]  = keyscale[9]  != true }
        else if hitZones.pc10keyPath.contains(xy) { keyscale[10] = keyscale[10] != true }
        else if hitZones.pc11keyPath.contains(xy) { keyscale[11] = keyscale[11] != true }
        
        updateView() 
     
        printLog("KeyscaleSensor mouseUp() detected.")
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
    
}



class KeyscaleViewHitZones {
    
    var scaleFactor : CGFloat = 1.0
    var transform = AffineTransform.identity
    
    let pc00keyPath = NSBezierPath()
    let pc01keyPath = NSBezierPath()
    let pc02keyPath = NSBezierPath()
    let pc03keyPath = NSBezierPath()
    let pc04keyPath = NSBezierPath()
    let pc05keyPath = NSBezierPath()
    let pc06keyPath = NSBezierPath()
    let pc07keyPath = NSBezierPath()
    let pc08keyPath = NSBezierPath()
    let pc09keyPath = NSBezierPath()
    let pc10keyPath = NSBezierPath()
    let pc11keyPath = NSBezierPath()
    
    
    init(scale: CGFloat = 1.0) {
        self.scaleFactor = scale
        definePaths()
        resizePaths(scale: scale)
    }
    
    func resizePaths(scale: CGFloat) {
        transform.scale(scale)
        pc00keyPath.transform(using: transform)
        pc01keyPath.transform(using: transform)
        pc02keyPath.transform(using: transform)
        pc03keyPath.transform(using: transform)
        pc04keyPath.transform(using: transform)
        pc05keyPath.transform(using: transform)
        pc06keyPath.transform(using: transform)
        pc07keyPath.transform(using: transform)
        pc08keyPath.transform(using: transform)
        pc09keyPath.transform(using: transform)
        pc10keyPath.transform(using: transform)
        pc11keyPath.transform(using: transform)
    }
    
    
    func definePaths() {
        
        //// pc00key Drawing
        pc00keyPath.move(to: NSPoint(x: 11.8, y: 27.17))
        pc00keyPath.curve(to: NSPoint(x: 12.42, y: 26.5), controlPoint1: NSPoint(x: 11.8, y: 26.78), controlPoint2: NSPoint(x: 12.08, y: 26.5))
        pc00keyPath.line(to: NSPoint(x: 17, y: 26.5))
        pc00keyPath.curve(to: NSPoint(x: 17, y: 3.5), controlPoint1: NSPoint(x: 17, y: 14.16), controlPoint2: NSPoint(x: 17, y: 3.5))
        pc00keyPath.curve(to: NSPoint(x: 15.5, y: 2), controlPoint1: NSPoint(x: 17, y: 2.67), controlPoint2: NSPoint(x: 16.33, y: 2))
        pc00keyPath.line(to: NSPoint(x: 2.5, y: 2))
        pc00keyPath.curve(to: NSPoint(x: 1, y: 3.5), controlPoint1: NSPoint(x: 1.67, y: 2), controlPoint2: NSPoint(x: 1, y: 2.67))
        pc00keyPath.line(to: NSPoint(x: 1, y: 63.5))
        pc00keyPath.curve(to: NSPoint(x: 2.5, y: 65), controlPoint1: NSPoint(x: 1, y: 64.33), controlPoint2: NSPoint(x: 1.67, y: 65))
        pc00keyPath.line(to: NSPoint(x: 11.8, y: 65))
        pc00keyPath.curve(to: NSPoint(x: 11.8, y: 27.12), controlPoint1: NSPoint(x: 11.8, y: 55.71), controlPoint2: NSPoint(x: 11.8, y: 27.12))
        pc00keyPath.line(to: NSPoint(x: 11.8, y: 27.17))
        pc00keyPath.close()
        
        //// pc01key Drawing
        pc01keyPath.move(to: NSPoint(x: 11.8, y: 27.12))
        pc01keyPath.curve(to: NSPoint(x: 12.42, y: 26.5), controlPoint1: NSPoint(x: 11.8, y: 26.78), controlPoint2: NSPoint(x: 12.08, y: 26.5))
        pc01keyPath.line(to: NSPoint(x: 20.98, y: 26.5))
        pc01keyPath.curve(to: NSPoint(x: 21.6, y: 27.12), controlPoint1: NSPoint(x: 21.32, y: 26.5), controlPoint2: NSPoint(x: 21.6, y: 26.78))
        pc01keyPath.line(to: NSPoint(x: 21.6, y: 64.88))
        pc01keyPath.curve(to: NSPoint(x: 20.98, y: 65.5), controlPoint1: NSPoint(x: 21.6, y: 65.22), controlPoint2: NSPoint(x: 21.32, y: 65.5))
        pc01keyPath.line(to: NSPoint(x: 12.42, y: 65.5))
        pc01keyPath.curve(to: NSPoint(x: 11.8, y: 64.88), controlPoint1: NSPoint(x: 12.08, y: 65.5), controlPoint2: NSPoint(x: 11.8, y: 65.22))
        pc01keyPath.line(to: NSPoint(x: 11.8, y: 27.12))
        pc01keyPath.close()
        
        //// pc02key Drawing
        pc02keyPath.move(to: NSPoint(x: 21.59, y: 65))
        pc02keyPath.curve(to: NSPoint(x: 29.41, y: 65), controlPoint1: NSPoint(x: 21.59, y: 65), controlPoint2: NSPoint(x: 25.88, y: 65))
        pc02keyPath.curve(to: NSPoint(x: 29.4, y: 64.88), controlPoint1: NSPoint(x: 29.4, y: 64.96), controlPoint2: NSPoint(x: 29.4, y: 64.92))
        pc02keyPath.line(to: NSPoint(x: 29.4, y: 27.12))
        pc02keyPath.curve(to: NSPoint(x: 30.02, y: 26.5), controlPoint1: NSPoint(x: 29.4, y: 26.78), controlPoint2: NSPoint(x: 29.68, y: 26.5))
        pc02keyPath.line(to: NSPoint(x: 34, y: 26.5))
        pc02keyPath.curve(to: NSPoint(x: 34, y: 2), controlPoint1: NSPoint(x: 34, y: 13.4), controlPoint2: NSPoint(x: 34, y: 2))
        pc02keyPath.line(to: NSPoint(x: 17, y: 2))
        pc02keyPath.curve(to: NSPoint(x: 17, y: 26.5), controlPoint1: NSPoint(x: 17, y: 2), controlPoint2: NSPoint(x: 17, y: 13.4))
        pc02keyPath.line(to: NSPoint(x: 20.98, y: 26.5))
        pc02keyPath.curve(to: NSPoint(x: 21.6, y: 27.12), controlPoint1: NSPoint(x: 21.32, y: 26.5), controlPoint2: NSPoint(x: 21.6, y: 26.78))
        pc02keyPath.curve(to: NSPoint(x: 21.6, y: 42.54), controlPoint1: NSPoint(x: 21.6, y: 27.12), controlPoint2: NSPoint(x: 21.6, y: 34.38))
        pc02keyPath.curve(to: NSPoint(x: 21.6, y: 64.88), controlPoint1: NSPoint(x: 21.6, y: 52.98), controlPoint2: NSPoint(x: 21.6, y: 64.88))
        pc02keyPath.curve(to: NSPoint(x: 21.59, y: 65), controlPoint1: NSPoint(x: 21.6, y: 64.92), controlPoint2: NSPoint(x: 21.6, y: 64.96))
        pc02keyPath.line(to: NSPoint(x: 21.59, y: 65))
        pc02keyPath.close()
        
        //// pc03key Drawing
        pc03keyPath.move(to: NSPoint(x: 29.4, y: 27.12))
        pc03keyPath.curve(to: NSPoint(x: 30.02, y: 26.5), controlPoint1: NSPoint(x: 29.4, y: 26.78), controlPoint2: NSPoint(x: 29.68, y: 26.5))
        pc03keyPath.line(to: NSPoint(x: 38.58, y: 26.5))
        pc03keyPath.curve(to: NSPoint(x: 39.2, y: 27.12), controlPoint1: NSPoint(x: 38.92, y: 26.5), controlPoint2: NSPoint(x: 39.2, y: 26.78))
        pc03keyPath.line(to: NSPoint(x: 39.2, y: 64.88))
        pc03keyPath.curve(to: NSPoint(x: 38.58, y: 65.5), controlPoint1: NSPoint(x: 39.2, y: 65.22), controlPoint2: NSPoint(x: 38.92, y: 65.5))
        pc03keyPath.line(to: NSPoint(x: 30.02, y: 65.5))
        pc03keyPath.curve(to: NSPoint(x: 29.4, y: 64.88), controlPoint1: NSPoint(x: 29.68, y: 65.5), controlPoint2: NSPoint(x: 29.4, y: 65.22))
        pc03keyPath.line(to: NSPoint(x: 29.4, y: 27.12))
        pc03keyPath.close()
        
        //// pc04key Drawing
        pc04keyPath.move(to: NSPoint(x: 50, y: 63.5))
        pc04keyPath.line(to: NSPoint(x: 50, y: 3.5))
        pc04keyPath.curve(to: NSPoint(x: 48.5, y: 2), controlPoint1: NSPoint(x: 50, y: 2.67), controlPoint2: NSPoint(x: 49.33, y: 2))
        pc04keyPath.line(to: NSPoint(x: 35.5, y: 2))
        pc04keyPath.curve(to: NSPoint(x: 34, y: 3.5), controlPoint1: NSPoint(x: 34.67, y: 2), controlPoint2: NSPoint(x: 34, y: 2.67))
        pc04keyPath.curve(to: NSPoint(x: 34, y: 26.5), controlPoint1: NSPoint(x: 34, y: 3.5), controlPoint2: NSPoint(x: 34, y: 14.16))
        pc04keyPath.line(to: NSPoint(x: 38.73, y: 26.5))
        pc04keyPath.curve(to: NSPoint(x: 39.35, y: 27.12), controlPoint1: NSPoint(x: 39.07, y: 26.5), controlPoint2: NSPoint(x: 39.35, y: 26.78))
        pc04keyPath.curve(to: NSPoint(x: 39.35, y: 65), controlPoint1: NSPoint(x: 39.35, y: 27.12), controlPoint2: NSPoint(x: 39.35, y: 50.63))
        pc04keyPath.line(to: NSPoint(x: 48.5, y: 65))
        pc04keyPath.curve(to: NSPoint(x: 50, y: 63.5), controlPoint1: NSPoint(x: 49.33, y: 65), controlPoint2: NSPoint(x: 50, y: 64.33))
        pc04keyPath.close()
        
        //// pc05key Drawing
        pc05keyPath.move(to: NSPoint(x: 60.3, y: 27.17))
        pc05keyPath.curve(to: NSPoint(x: 60.92, y: 26.5), controlPoint1: NSPoint(x: 60.3, y: 26.78), controlPoint2: NSPoint(x: 60.58, y: 26.5))
        pc05keyPath.line(to: NSPoint(x: 67, y: 26.5))
        pc05keyPath.curve(to: NSPoint(x: 67, y: 3.5), controlPoint1: NSPoint(x: 67, y: 14.16), controlPoint2: NSPoint(x: 67, y: 3.5))
        pc05keyPath.curve(to: NSPoint(x: 65.5, y: 2), controlPoint1: NSPoint(x: 67, y: 2.67), controlPoint2: NSPoint(x: 66.33, y: 2))
        pc05keyPath.line(to: NSPoint(x: 51.5, y: 2))
        pc05keyPath.curve(to: NSPoint(x: 50, y: 3.5), controlPoint1: NSPoint(x: 50.67, y: 2), controlPoint2: NSPoint(x: 50, y: 2.67))
        pc05keyPath.line(to: NSPoint(x: 50, y: 63.5))
        pc05keyPath.curve(to: NSPoint(x: 51.5, y: 65), controlPoint1: NSPoint(x: 50, y: 64.33), controlPoint2: NSPoint(x: 50.67, y: 65))
        pc05keyPath.line(to: NSPoint(x: 60.3, y: 65))
        pc05keyPath.curve(to: NSPoint(x: 60.3, y: 27.12), controlPoint1: NSPoint(x: 60.3, y: 55.71), controlPoint2: NSPoint(x: 60.3, y: 27.12))
        pc05keyPath.line(to: NSPoint(x: 60.3, y: 27.17))
        pc05keyPath.close()
        
        //// pc06key Drawing
        pc06keyPath.move(to: NSPoint(x: 60.15, y: 27.12))
        pc06keyPath.curve(to: NSPoint(x: 60.77, y: 26.5), controlPoint1: NSPoint(x: 60.15, y: 26.78), controlPoint2: NSPoint(x: 60.43, y: 26.5))
        pc06keyPath.line(to: NSPoint(x: 69.33, y: 26.5))
        pc06keyPath.curve(to: NSPoint(x: 69.95, y: 27.12), controlPoint1: NSPoint(x: 69.67, y: 26.5), controlPoint2: NSPoint(x: 69.95, y: 26.78))
        pc06keyPath.line(to: NSPoint(x: 69.95, y: 64.88))
        pc06keyPath.curve(to: NSPoint(x: 69.33, y: 65.5), controlPoint1: NSPoint(x: 69.95, y: 65.22), controlPoint2: NSPoint(x: 69.67, y: 65.5))
        pc06keyPath.line(to: NSPoint(x: 60.77, y: 65.5))
        pc06keyPath.curve(to: NSPoint(x: 60.15, y: 64.88), controlPoint1: NSPoint(x: 60.43, y: 65.5), controlPoint2: NSPoint(x: 60.15, y: 65.22))
        pc06keyPath.line(to: NSPoint(x: 60.15, y: 27.12))
        pc06keyPath.close()
        
        //// pc07key Drawing
        pc07keyPath.move(to: NSPoint(x: 78.3, y: 27.2))
        pc07keyPath.curve(to: NSPoint(x: 78.92, y: 26.5), controlPoint1: NSPoint(x: 78.32, y: 26.76), controlPoint2: NSPoint(x: 78.59, y: 26.5))
        pc07keyPath.line(to: NSPoint(x: 83, y: 26.5))
        pc07keyPath.curve(to: NSPoint(x: 83, y: 3.5), controlPoint1: NSPoint(x: 83, y: 14.16), controlPoint2: NSPoint(x: 83, y: 3.5))
        pc07keyPath.curve(to: NSPoint(x: 81.5, y: 2), controlPoint1: NSPoint(x: 83, y: 2.67), controlPoint2: NSPoint(x: 82.33, y: 2))
        pc07keyPath.line(to: NSPoint(x: 68.5, y: 2))
        pc07keyPath.curve(to: NSPoint(x: 67, y: 3.5), controlPoint1: NSPoint(x: 67.67, y: 2), controlPoint2: NSPoint(x: 67, y: 2.67))
        pc07keyPath.curve(to: NSPoint(x: 67, y: 18.67), controlPoint1: NSPoint(x: 67, y: 3.5), controlPoint2: NSPoint(x: 67, y: 9.97))
        pc07keyPath.curve(to: NSPoint(x: 67, y: 26.5), controlPoint1: NSPoint(x: 67, y: 21.13), controlPoint2: NSPoint(x: 67, y: 23.78))
        pc07keyPath.line(to: NSPoint(x: 69.48, y: 26.5))
        pc07keyPath.curve(to: NSPoint(x: 70.1, y: 27.12), controlPoint1: NSPoint(x: 69.82, y: 26.5), controlPoint2: NSPoint(x: 70.1, y: 26.78))
        pc07keyPath.curve(to: NSPoint(x: 70.1, y: 65), controlPoint1: NSPoint(x: 70.1, y: 27.12), controlPoint2: NSPoint(x: 70.1, y: 55.71))
        pc07keyPath.line(to: NSPoint(x: 78.3, y: 65))
        pc07keyPath.curve(to: NSPoint(x: 78.3, y: 27.17), controlPoint1: NSPoint(x: 78.3, y: 55.93), controlPoint2: NSPoint(x: 78.3, y: 28.45))
        pc07keyPath.line(to: NSPoint(x: 78.3, y: 27.2))
        pc07keyPath.close()
        
        //// pc08key Drawing
        pc08keyPath.move(to: NSPoint(x: 78.1, y: 27.12))
        pc08keyPath.curve(to: NSPoint(x: 78.72, y: 26.5), controlPoint1: NSPoint(x: 78.1, y: 26.78), controlPoint2: NSPoint(x: 78.38, y: 26.5))
        pc08keyPath.line(to: NSPoint(x: 87.28, y: 26.5))
        pc08keyPath.curve(to: NSPoint(x: 87.9, y: 27.12), controlPoint1: NSPoint(x: 87.62, y: 26.5), controlPoint2: NSPoint(x: 87.9, y: 26.78))
        pc08keyPath.line(to: NSPoint(x: 87.9, y: 64.88))
        pc08keyPath.curve(to: NSPoint(x: 87.28, y: 65.5), controlPoint1: NSPoint(x: 87.9, y: 65.22), controlPoint2: NSPoint(x: 87.62, y: 65.5))
        pc08keyPath.line(to: NSPoint(x: 78.72, y: 65.5))
        pc08keyPath.curve(to: NSPoint(x: 78.1, y: 64.88), controlPoint1: NSPoint(x: 78.38, y: 65.5), controlPoint2: NSPoint(x: 78.1, y: 65.22))
        pc08keyPath.line(to: NSPoint(x: 78.1, y: 27.12))
        pc08keyPath.close()
        
        //// pc09key Drawing
        pc09keyPath.move(to: NSPoint(x: 96.3, y: 27.2))
        pc09keyPath.curve(to: NSPoint(x: 96.92, y: 26.5), controlPoint1: NSPoint(x: 96.32, y: 26.76), controlPoint2: NSPoint(x: 96.59, y: 26.5))
        pc09keyPath.line(to: NSPoint(x: 100, y: 26.5))
        pc09keyPath.curve(to: NSPoint(x: 100, y: 3.5), controlPoint1: NSPoint(x: 100, y: 14.16), controlPoint2: NSPoint(x: 100, y: 3.5))
        pc09keyPath.curve(to: NSPoint(x: 98.5, y: 2), controlPoint1: NSPoint(x: 100, y: 2.67), controlPoint2: NSPoint(x: 99.33, y: 2))
        pc09keyPath.line(to: NSPoint(x: 84.5, y: 2))
        pc09keyPath.curve(to: NSPoint(x: 83, y: 3.5), controlPoint1: NSPoint(x: 83.67, y: 2), controlPoint2: NSPoint(x: 83, y: 2.67))
        pc09keyPath.curve(to: NSPoint(x: 83, y: 18.9), controlPoint1: NSPoint(x: 83, y: 3.5), controlPoint2: NSPoint(x: 83, y: 10.09))
        pc09keyPath.curve(to: NSPoint(x: 83, y: 26.5), controlPoint1: NSPoint(x: 83, y: 21.3), controlPoint2: NSPoint(x: 83, y: 23.86))
        pc09keyPath.line(to: NSPoint(x: 87.48, y: 26.5))
        pc09keyPath.curve(to: NSPoint(x: 88.1, y: 27.12), controlPoint1: NSPoint(x: 87.82, y: 26.5), controlPoint2: NSPoint(x: 88.1, y: 26.78))
        pc09keyPath.curve(to: NSPoint(x: 88.1, y: 65), controlPoint1: NSPoint(x: 88.1, y: 27.12), controlPoint2: NSPoint(x: 88.1, y: 55.71))
        pc09keyPath.line(to: NSPoint(x: 96.3, y: 65))
        pc09keyPath.curve(to: NSPoint(x: 96.3, y: 27.17), controlPoint1: NSPoint(x: 96.3, y: 55.93), controlPoint2: NSPoint(x: 96.3, y: 28.45))
        pc09keyPath.line(to: NSPoint(x: 96.3, y: 27.2))
        pc09keyPath.close()
        
        //// pc10key Drawing
        pc10keyPath.move(to: NSPoint(x: 96.05, y: 27.12))
        pc10keyPath.curve(to: NSPoint(x: 96.67, y: 26.5), controlPoint1: NSPoint(x: 96.05, y: 26.78), controlPoint2: NSPoint(x: 96.33, y: 26.5))
        pc10keyPath.line(to: NSPoint(x: 105.23, y: 26.5))
        pc10keyPath.curve(to: NSPoint(x: 105.85, y: 27.12), controlPoint1: NSPoint(x: 105.57, y: 26.5), controlPoint2: NSPoint(x: 105.85, y: 26.78))
        pc10keyPath.line(to: NSPoint(x: 105.85, y: 64.88))
        pc10keyPath.curve(to: NSPoint(x: 105.23, y: 65.5), controlPoint1: NSPoint(x: 105.85, y: 65.22), controlPoint2: NSPoint(x: 105.57, y: 65.5))
        pc10keyPath.line(to: NSPoint(x: 96.67, y: 65.5))
        pc10keyPath.curve(to: NSPoint(x: 96.05, y: 64.88), controlPoint1: NSPoint(x: 96.33, y: 65.5), controlPoint2: NSPoint(x: 96.05, y: 65.22))
        pc10keyPath.line(to: NSPoint(x: 96.05, y: 27.12))
        pc10keyPath.close()
        
        //// pc11key Drawing
        pc11keyPath.move(to: NSPoint(x: 116, y: 63.5))
        pc11keyPath.line(to: NSPoint(x: 116, y: 3.5))
        pc11keyPath.curve(to: NSPoint(x: 114.5, y: 2), controlPoint1: NSPoint(x: 116, y: 2.67), controlPoint2: NSPoint(x: 115.33, y: 2))
        pc11keyPath.line(to: NSPoint(x: 101.5, y: 2))
        pc11keyPath.curve(to: NSPoint(x: 100, y: 3.5), controlPoint1: NSPoint(x: 100.67, y: 2), controlPoint2: NSPoint(x: 100, y: 2.67))
        pc11keyPath.curve(to: NSPoint(x: 100, y: 26.5), controlPoint1: NSPoint(x: 100, y: 3.5), controlPoint2: NSPoint(x: 100, y: 14.16))
        pc11keyPath.line(to: NSPoint(x: 105.48, y: 26.5))
        pc11keyPath.curve(to: NSPoint(x: 106.1, y: 27.12), controlPoint1: NSPoint(x: 105.82, y: 26.5), controlPoint2: NSPoint(x: 106.1, y: 26.78))
        pc11keyPath.curve(to: NSPoint(x: 106.1, y: 65), controlPoint1: NSPoint(x: 106.1, y: 27.12), controlPoint2: NSPoint(x: 106.1, y: 55.71))
        pc11keyPath.line(to: NSPoint(x: 114.5, y: 65))
        pc11keyPath.curve(to: NSPoint(x: 116, y: 63.5), controlPoint1: NSPoint(x: 115.33, y: 65), controlPoint2: NSPoint(x: 116, y: 64.33))
        pc11keyPath.close()
    }
    
}
