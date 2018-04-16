//
//  MasterTempoBarBeatModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/5/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit


final class MasterTempoBarBeatModel {
    
    var bags = DisposeBagStore()
    
    let slaveToLink : Property<Bool>              = Property(true)
    let linkUpdater : Property<LinkBeatBpmUpdate> = Property(LinkBeatBpmUpdate(beat: 0.0, bpm: 128.0))
    let masterTempo : Property<Float64>           = Property(132.00)
    
    var linkUpdaterBag : DisposeBag?
    
    func resetBag() {
        linkUpdaterBag = bags.makeNew("LinkUpdater")
    }
    
    
}

