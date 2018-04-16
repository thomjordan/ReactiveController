//
//  InputPointReactors.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class InputPointReactors : SafeIndexArray, DisposeBagProvider {
    
    var bag: DisposeBag = DisposeBag()
    
    typealias Element = InputPointReactor
    
    weak var models : InputPointModels!
    
    var contents : Array<Element> = []
    
    init(_ models: InputPointModels) {
        
        self.models = models
        
        observeModelsArray( models )
    }
    
    func clean() { for e in contents { e.clean() } }
}



extension InputPointReactors {
    
    func observeModelsArray(_ inputModels: InputPointModels) {
        
        inputModels.observeCollection { inlets in // [weak self] inlets in
            
            switch inlets.change {
                
            case .inserts(let indices):
                
                for index in indices {
                    
                    let mdl = inputModels.contents[index]
                    
                    let inputReactor = InputPointReactor( mdl )
                    
                    self.contents.insert( inputReactor, at: index )
                }
                
            case .deletes(let indices):
                
                for index in indices.reversed(){
                    
                    let _ = self.contents.remove(at: index)
                }
                
                
            default: break
                
            }}.dispose(in: bag)
    }
}
