//
//  InputPointModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond



class InputPointModel : ConnecterModel {
    
    var header : ConnectorInfo!
    
    var pin    : Connecter!
    
    var bag    : DisposeBag = DisposeBag()
    
    var refresh : ( () -> () )?
    
    var incomingConnection : ConnectionModel?
    
    var isOccupied : Bool { return incomingConnection != nil ? true : false }
    
    
    required init(_ pin: Connecter, _ num: Int, _ info: String) {
        
        self.header = ConnectorInfo.genInput( num, info )
        
        self.pin = pin
    }
    
}
