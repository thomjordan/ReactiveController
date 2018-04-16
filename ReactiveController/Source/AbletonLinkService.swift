//
//  AbletonLinkService.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/10/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import AbletonLinkShim

struct LinkBeatBpmUpdate {
    let beat : Float64
    let bpm  : Float64
}

final class AbletonLinkService {
    
    static let API = AbletonLinkService()
    
    var app    : App?
    var client = AbletonLinkClient()
    
    func setupLink(for context: App) {
        self.app = context
        let updater : (Double, Double) -> () = { [weak self] beat, bpm in
            let linkVals = LinkBeatBpmUpdate(beat: Float64(beat), bpm: Float64(bpm))
            self?.app?.toolbarCxt?.tempoModel.linkUpdater.next(linkVals)
        }
        client.setUpdatingCallback(updater)
        enableAfterResolvingTempo()
    }

    func removeLink() {
        client.setEnabled(false)
    }
    
    func enableAfterResolvingTempo() {
        client.setEnabled(true)
        let beatAndBPM = client.getBeatWithBPM()
        let resolvedTempo = beatAndBPM?.bpm ?? app?.toolbarCxt?.tempoModel.masterTempo.value ?? 125.0
        client.setBeat(0.0, andBPM: resolvedTempo)
        client.invokeUpdatingCallback(beat: 0.0, bpm: resolvedTempo) // 'beat' is arbirary here
    }
}





