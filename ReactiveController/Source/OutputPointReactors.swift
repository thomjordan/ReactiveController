//
//  OutputPointReactors.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class OutputPointReactors : SafeIndexArray, DisposeBagProvider {
    
    var bag: DisposeBag = DisposeBag() 
    
    typealias Element = OutputPointReactor
    
    weak var models : OutputPointModels!
    
    var contents : Array<Element> = []
    
    init(_ models: OutputPointModels) {
        
        self.models = models
        
        observeModelsArray( models )
    }
    
    func clean() { for e in contents { e.clean() } } 
}



extension OutputPointReactors {
    
    func observeModelsArray(_ outputModels: OutputPointModels) {
        
        outputModels.observeCollection { [weak self] outlets in
            
            switch outlets.change {
                
            case .inserts(let indices):
                
                for index in indices.reversed() {
                    
                    let outputReactor = OutputPointReactor( outputModels.contents[index] )
                    
                    self?.contents.insert( outputReactor, at: index )
                }
                
            case .deletes(let indices):
                
                for index in indices.reversed(){
                    
                    let _ = self?.contents.remove(at: index)
                }
                
            default: break
                
            }}.dispose(in: bag)
    }
}
