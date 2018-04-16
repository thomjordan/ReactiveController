//
//  Dispatch.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

// https://developer.apple.com/documentation/dispatch/dispatchqos

///*
import Cocoa
import ReactiveKit


class Dispatch {
    
    static var multiInitiated      = DispatchQueue(label: "net.thomjordan.multiInitiated",   qos: .userInitiated,   attributes: .concurrent)
    static var multiInteractive    = DispatchQueue(label: "net.thomjordan.multiInteractive", qos: .userInteractive, attributes: .concurrent)
  //  static var multiInitiatedKey   = DispatchSpecificKey<Void>()
  //  static var multiInteractiveKey = DispatchSpecificKey<Void>()
    
  //  init() {
        
    //    Dispatch.multiInitiated.setSpecific(key: Dispatch.multiInitiatedKey, value: ())
    //    Dispatch.multiInteractive.setSpecific(key: Dispatch.multiInteractiveKey, value: ())
        
       // let q1 = DispatchQueue.getSpecific(key: Dispatch.multiInitiatedKey)
       // let q2 = DispatchQueue.getSpecific(key: Dispatch.multiInteractiveKey)
   // }
}
//*/
 
