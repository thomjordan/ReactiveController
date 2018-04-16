//
//  OutputPointReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class OutputPointReactor : ConnecterReactor {
    
    typealias ModelType = OutputPointModel
    
    weak var model : OutputPointModel!
    weak var vc    : ConnectorPointViewController?
    
    var activeConnections : [ConnectionReactor] = []
    
    var outputTask : ( () -> SignalTaskType )?
    
    init(_ model: OutputPointModel) {
        
        self.model = model
    }
}


extension OutputPointReactor {
    
    func createScene() -> ConnectorPointViewController {
        
        let connectorPointVC = ConnectorPointViewController()
        
        vc = connectorPointVC 
        
        return connectorPointVC
    }   
}


extension OutputPointReactor {
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.vc?.view.needsDisplay = true
        }
    }
    
    
    func addOutputConnection(_ connection: ConnectionReactor) {
        
        activeConnections.append(connection)
    }
    
    
    func removeOutputConnection(_ connection: ConnectionReactor) {  // assumes no duplicate connections
        
        for (index, plugged) in activeConnections.enumerated() {
            
            if plugged === connection {
                
                activeConnections.remove(at: index)
                
                return
            }
        }
    }
    
    func removeAllOutputConnections() {
        
        activeConnections = []
    }
    
    func setStringCode(_ str: StringCoder) {
        
        pin.asStringCoder()?.value = str
        
        printLog("OutputPointReactor : setStringCode : \(str)")
    }
}
