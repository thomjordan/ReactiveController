//
//  ConnectorPointViewController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit
import Bond


class ConnectorPointViewController : NSViewController {
    
    let emptyColor    = NSColor.darkGray
    
    let occupiedColor = NSColor.yellow
    
    let selectedColor = Colors.goldenSunYellow
    
    var isOccupied : Property<Bool> = Property( false )
    
    var center : NSPoint?
    
    var radius : CGFloat?

    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        self.view = ConnectorPointView(vc: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    
    func placeConnectorInFrame(center: NSPoint, radius: CGFloat) {
        
        self.center = center
        
        self.radius = radius 
        
        view.frame = NSMakeRect(center.x-radius, center.y-radius, radius*2.0, radius*2.0)
        
        updateView()
        
    }
    
    
    func connectorColor() -> NSColor {
        
        let color = isOccupied.value ? occupiedColor : emptyColor
        
        return color
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.view.needsDisplay = true
//        }
//    }
    
}
