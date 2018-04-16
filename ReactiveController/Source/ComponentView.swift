//
//  ComponentView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
//import Neon

 

// MARK: - ComponentView

class ComponentView : NSBox {
    
    let highlightColor = Colors.goldenSunYellow
    
    let specialHighlightColor = Colors.atlanticBlue
    
    let bothHighlightColor = Colors.glowstickGreen
    
    let regBorderColor = NSColor.darkGray
    
    var isSelected  : () -> Bool = { false }
    
    var isDraggable : () -> Bool = { false }
    
    weak var vc : ComponentViewController?
    
    var connectorsView = ComponentObjectInterfaceView(bodyFrame: NSMakeRect(0,0,1,1))
    
    var viewContent : ComponentContentView!
    
    let connectionAxisPad : CGFloat = 14
    
    let otherAxisPad : CGFloat = 4
    
    
    init(_ content: ComponentContentView) {
        
        super.init(frame: connectorsView.frame)
        
        content.containerView = self 
        
        viewContent = content
    }
    
    
    func setup() {
        
        arrangeInterfaceAndContent()
        
        sizeToFit()
        
        setFrameFromContentFrame(viewContent.frame)
        
        boxType      = .custom
        
        borderType   = .lineBorder
        
        borderWidth  = 3
        
        cornerRadius = 10
        
        borderColor  = regBorderColor
        
        contentViewMargins = NSMakeSize(0, 0)
        
        wantsLayer           = true
        layer?.masksToBounds = true
        
      //  arrangeInterfaceAndContent()
    }
    
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
    
    
    override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    
    
    
    func arrangeInterfaceAndContent() {
        
        func middleStuff() {
            
            addSubview( connectorsView )
            
            connectorsView.anchorInCenter(width: connectorsView.frame.width, height: connectorsView.frame.height)
            
            sizeToFit()
            
            addSubview(viewContent)
            
            sizeToFit()
            
        }
        
        guard let vc = vc else { return }
        
        if vc.generatesOwnInput {
            
            connectorsView.bodySize = NSMakeSize(viewContent.frame.width + otherAxisPad*2.0, viewContent.frame.height + connectionAxisPad)
            
            middleStuff()
            
            viewContent.align(.underCentered, relativeTo: connectorsView, padding: 0, width: viewContent.frame.width, height: viewContent.frame.height)
            
            viewContent.frame.origin = NSMakePoint( viewContent.frame.origin.x + 0, viewContent.frame.origin.y + viewContent.frame.size.height + (connectionAxisPad/2) )
            
            sizeToFit()
            
        } else {
            
            connectorsView.bodySize = NSMakeSize(viewContent.frame.width + connectionAxisPad*2.0, viewContent.frame.height + otherAxisPad + 2.0)
            
            middleStuff()
            
            viewContent.align(.underCentered, relativeTo: connectorsView, padding: 0, width: viewContent.frame.width, height: viewContent.frame.height)
            
            
            viewContent.frame.origin = NSMakePoint( viewContent.frame.origin.x + 1.0, viewContent.frame.origin.y + viewContent.frame.size.height + otherAxisPad )
            
            setFrameFromContentFrame(connectorsView.frame)  // + connectionAxisPad/8.0
            
            sizeToFit()
        }
        
        if vc.generatesOwnOutput { // if component has no outputs, remove the extra space
            
            let size = connectorsView.frame.size
            
            connectorsView.frame.size = NSMakeSize(size.width - connectionAxisPad + 2.0, size.height)
            
            setFrameFromContentFrame(connectorsView.frame)
            
            sizeToFit()
        }
    }
    
    
    func highlightBox(_ state:Bool) {
        
        borderColor = state ? highlightColor : regBorderColor
        
        updateView()
        
    }
    
    
    func highlightBox(_ state:ComponentBoxHighlightState) {
        
        borderColor = state.getColor()
        
        updateView()
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
    
}



enum ComponentBoxHighlightState {
    
    case selected
    
    case specialSelected
    
    case bothSelected
    
    case noneSelected
    
    
    func getColor() -> NSColor {
        
        switch self {
            
        case .selected:        return Colors.goldenSunYellow
            
        case .specialSelected: return Colors.atlanticBlue
            
        case .bothSelected:    return Colors.glowstickGreen
            
        case .noneSelected:    return NSColor.darkGray
            
        }
    }
}



//  MARK: - ComponentObjectInterfaceView



class ComponentObjectInterfaceView : NSBox { 
    
    
    var bodySize  : NSSize = NSMakeSize(144,144) {
        
        didSet { self.frame.size = bodySize }
        
    }
    
    
    init(bodyFrame: NSRect) {
        
        bodySize = bodyFrame.size
        
        super.init(frame: NSMakeRect(0,0,bodySize.width,bodySize.height))
        
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        ComponentObjectInterfaceStyleKit.drawObjectInterface(theSizeFrame: bodySize)
        
    }
    
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
}

