//
//  ConnecterReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/9/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol ConnecterReactor {
    
    associatedtype ModelType : ConnecterModel
    
    var model : ModelType! { get set }
}


extension ConnecterReactor {
    
    var portnum : Int { return model.header.portnum }
    
    var pin : Connecter! { return model.pin }
    
    var bag : DisposeBag { return model.bag }
    
    var refresh : ( () -> () )? { return model.refresh }
    
    func setRefresh(newBlock: @escaping (() -> ()) ) { model.refresh = newBlock }
    
    func setPin(_ newPin: Connecter ) { model.pin  = newPin }
    
    func addToBag(_ newDisp: Disposable ) { model.bag.add(disposable: newDisp) }
    
    func clean() { model.dispose() }
}



