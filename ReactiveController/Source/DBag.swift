//
//  DBag.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/5/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

typealias DisposeBagStore = [ String : DBag ]

class DBag : DisposeBagProvider {
    
    var bag: DisposeBag = DisposeBag()
    
    func dispose() { bag.dispose() }
}

extension Dictionary where Key == String, Value == DBag {
    
    mutating func makeNew(_ name: String) -> DisposeBag? {
        self[name]?.dispose()
        self[name] = nil
        self[name] = DBag()
        return self[name]?.bag
    }
}
