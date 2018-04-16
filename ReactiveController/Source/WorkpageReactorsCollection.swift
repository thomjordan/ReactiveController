//
//  WorkpageReactorsCollection.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkpageReactorsCollection : PagesCollectable {
    
    var  selectedPageNum : Property<Int> = Property(0)
    
    var  thePages : MutableObservableArray<WorkpageReactor> = MutableObservableArray( [] )

    
    func deletePage(at index: Int) {
        
        var temp : WorkpageReactor? = removePage(at: index)
        
        temp?.bag.dispose()
        
        temp = nil
    }

}

