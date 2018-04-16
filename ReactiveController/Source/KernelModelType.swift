//
//  KernelModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/9/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol KernelModelType : class, Codable {
    func publish(to view: ComponentContentView)
}


