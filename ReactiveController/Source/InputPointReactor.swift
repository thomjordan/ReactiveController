//
//  InputPointReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond



class InputPointReactor : ConnecterReactor {
    
    typealias ModelType = InputPointModel
    
    weak var model : InputPointModel!
    weak var vc    : ConnectorPointViewController?  // try to refactor out
    
    var activeConnection : ConnectionReactor?
    
    init(_ m: InputPointModel) {
        self.model = m
    }
}



extension InputPointReactor {
    
    func createScene() -> ConnectorPointViewController {
        
        let connectorPointVC = ConnectorPointViewController()
        
        vc = connectorPointVC 
        
        return connectorPointVC
    }
}



extension InputPointReactor {
    
    var isOccupied : Bool { return activeConnection != nil ? true : false }
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.vc?.view.needsDisplay = true
        }
    }
    
    func assignInputConnection(_ connection: ConnectionReactor) {
        
        activeConnection = connection
    }
    
    func removeInputConnection() {
        
        activeConnection?.targetUnit?.model?.deleteIncomingConnectionByInputNumber(portnum)
    }
}
