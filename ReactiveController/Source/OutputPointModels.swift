//
//  OutputPointModels.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class OutputPointModels : SafeIndexObservableArray {
    
    typealias Element = OutputPointModel
    
    var contents : MutableObservableArray<Element> = MutableObservableArray( [] )
    
}


