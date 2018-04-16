//
//  AppContext.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 2/3/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Neon


class InspectorPanelViewController : NSViewController {
    
 //   @IBOutlet weak var stackView: NSStackView!
    
    var theMC : MainCoordinator!
    
    var documentView : NSView? {
        
        guard let docView = ((view as? NSScrollView)?.documentView as? NSView) else { return nil }
        
        return docView 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateAttributesViewsDisplay() {
        
        guard let docView = documentView else { return }
        
        for sv in docView.subviews { sv.removeFromSuperview() }
        
      //  for sv in stackView.views { stackView.removeView(sv) }
        
        printLog("InspectorAreaViewControl: REMOVING ALL CONNECTION SUBVIEWS")
        
        guard let cords = theMC.vcGateway?.workspaceVC.currentConnections else { return }
        
        for cord in cords {
            
          //  if cord.isSelected {
                
                let attrView = cord.attrView
                
                docView.addSubview(attrView!)
              //  self.view.needsDisplay = true
            
              //  stackView.addView(attrView, inGravity: .Bottom)
                
                printLog("InspectorAreaViewControl: ADDED A CONNECTION SUBVIEW for source: \(attrView.hostConnection.sourceOutput.name)")
          //  }
        }
        
   //     /*
        for (index, sv) in docView.subviews.enumerated() {
            
            if index == 0 { sv.anchorToEdge(.Top, padding: 0, width: sv.frame.width, height: sv.frame.height) }
                
            else if index > 0 {
                
                sv.align(.UnderCentered, relativeTo: docView.subviews[index-1], padding: -10, width: sv.frame.width, height: sv.frame.height)
            }
        }
    //    */
        
        view.needsDisplay = true
    }

}

//class InspectorStackViewDelegate : NSObject, NSStackViewDelegate { }


 
