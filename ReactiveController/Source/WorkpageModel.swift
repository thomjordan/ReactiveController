//
//  WorkpageModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkpageModel : Selectable, Codable {
    
    private(set) var loadedComponents  : [ComponentModel]?
    private(set) var loadedGridActive  : Bool?
    private(set) var componentsLoader : ( () -> () )?
    
    var name         : Property<String> = Property("")
    
    var uniqID       : Property<Int> = Property(0)
    
    var isSelected   : Bool = false
    
    var components   : MutableObservableArray<ComponentModel> = MutableObservableArray( [] )
    
    var gridIsActive : Property<Bool> = Property(true)
    
    var bag: DisposeBag = DisposeBag()
    
    required init() { }
    
    func observeComponents(with observer: @escaping (ObservableArrayEvent<ComponentModel>) -> Void) -> Disposable {
        
        let disp = components
            
            .observeNext(with: observer)
        
        return disp
    }
    
    func select()   { isSelected = true  }
    
    func deselect() { isSelected = false }
    
    enum CodingKeys : String, CodingKey {
        case components
        case activeGrid
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        
        self.components   = MutableObservableArray( Array<ComponentModel>() )
        self.gridIsActive = Property(true)
        
        self.loadedComponents = try vals.decode( [ComponentModel].self, forKey: .components )
        self.loadedGridActive = try vals.decode( Bool.self, forKey: .activeGrid )
        
        self.componentsLoader = {
            guard let compobjects = self.loadedComponents, let activegrid = self.loadedGridActive else { return }
            for cmodel in compobjects { 
                self.components.append( cmodel )
            }
            self.gridIsActive.value = activegrid
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( components.array, forKey: .components )
        try bin.encode( gridIsActive.value, forKey: .activeGrid )
    }
}
