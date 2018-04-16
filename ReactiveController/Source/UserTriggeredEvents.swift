//
//  UserTriggeredEvents.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/19/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa 

typealias MouseDownEvent = (sender: NSEvent, winloc: NSPoint, viewloc: NSPoint)
typealias MouseDragEvent = (winloc: NSPoint, viewloc: NSPoint, sender: NSEvent)
typealias MouseUpEvent   = (viewloc: NSPoint, sender: NSEvent, winloc: NSPoint)


