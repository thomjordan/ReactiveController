//
//  WorkpageViewsCollection.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/23/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkpageViewsCollection : PagesCollectable {
    
    var selectedPageNum : Property<Int> = Property(0)
    
    var thePages     : MutableObservableArray<WorkpageView> = MutableObservableArray( [] )
    
    var pageCount    : Int { return thePages.count }
    
    
    func deletePage(at index: Int) {
        
        var temp : WorkpageView? = removePage(at: index)
        
        temp = nil
        
        let _ = temp
    }
}
