//
//  MainToolbarContext.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/5/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import AudioToolbox


class MainToolbarContext {
    
    var bags = DisposeBagStore() 
    
    var tempoModel           = MasterTempoBarBeatModel()
    let transportModel       = TransportControlStateModel()
    let simpleSeq            = SimpleSequencer(numtracks: 1)
    
    var toolbar              : NSToolbar!
    var toolbarDelegate      : MainToolbarDelegate!
    var transportMultiButton : TransportControlButtonView? { return toolbarDelegate?.transportButton.view as? TransportControlButtonView }
    var transportState       : Property<TransportControlStateModel.TransportStatus>? { return transportModel.transportState_ }
    
    init(with toolbar: NSToolbar) {
        self.toolbar           = toolbar
        self.toolbarDelegate   = MainToolbarDelegate( toolbar: self.toolbar! )
        self.toolbar!.delegate = self.toolbarDelegate!
        setupViewsForToolbarItems()
        restartLinkUpdatesObserver()
    }
    
    func setupViewsForToolbarItems() {
        toolbarDelegate.tempoTextField.view  = MasterTempoTextField(frame: NSMakeRect(0,0,36,22), model: tempoModel)
        toolbarDelegate.transportButton.view = TransportControlButtonView(origin: NSPoint(x: 2, y: 2), model: transportModel)
    }
}


extension MainToolbarContext {
    
    func restartLinkUpdatesObserver() {
        guard let linkUpdaterBag = bags.makeNew("LinkUpdater") else { return }
        
        tempoModel.linkUpdater
            .observeNext {
                self.tempoModel.masterTempo.next( $0.bpm )
                self.toolbarDelegate.updateTempoField() 
            }
            .dispose(in: linkUpdaterBag)
    }
    
    
    
}

/* Transport */

extension MainToolbarContext {
    
    func restartTransportObserver() {
        guard let transportBag = bags.makeNew("TransportStatus") else { return }
        
        transportState?.zipPrevious()
            .observeNext { [weak self] eventPair in
                switch eventPair {
                case ( .some(.stopClicked),  .defaultState ) : self?.simpleSeq.stop() ; self?.simpleSeq.cue()
                case ( .some(.playClicked),  .playEngaged  ) : self?.simpleSeq.play()
                case ( .some(.restartPlay),  .playEngaged  ) : self?.simpleSeq.cue()
                case ( .some(.stoppingPlay), .defaultState ) : self?.simpleSeq.stop()
                default: ()
                }
        }.dispose(in: transportBag)
    }
}

/* MainSequencer */

extension MainToolbarContext {
    
    func setupSeq() {
        simpleSeq.tracks[0].formatLoop( 8192.0 )
        simpleSeq.cue()
    }
    
    func readCurrentBeatLocation() -> MusicTimeStamp {
        return simpleSeq.read()
    }
    
    func setBeat(_ beat: Float64, withBPM: Float64) {
        simpleSeq.defineTempo(withBPM)
        simpleSeq.player.setTime(beat)
    }
}

// TO DO: Implement a close() method for calling when the app is shutting down.

