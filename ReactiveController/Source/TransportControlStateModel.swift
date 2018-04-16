//
//  TransportControlStateModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/5/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class TransportControlStateModel {
    
    enum RunningMode {
        case playing
        case stopped
    }
    
    enum ButtonPressStatus {
        case pressingPlay
        case pressingStop
        case nonaction
    }
    
    enum TransportStatus : Int {
        case stopClicked  = 0
        case defaultState = 1
        case playClicked  = 2
        case playEngaged  = 3 
        case restartPlay  = 4
        case stoppingPlay = 5
    }
    
    var transportState_ : Property<TransportStatus> = Property( .defaultState )
    
    var transportState : TransportStatus = .defaultState {
        didSet { printLog("TransportControlButtonView:transportState changed to \(transportState)")
            transportState_.value = transportState
        }
    }
    
    var transportMode  : RunningMode = .stopped // { didSet { triggerModeChangeFrom(oldValue, to: transportMode)} }
    
    var pressingStatus : ButtonPressStatus = .nonaction
    
    
    func playButtonClicked() {
        if transportState == .defaultState {
            pressingStatus = .pressingPlay
            transportState = .playClicked
        }
        else if transportState == .playEngaged {
            pressingStatus = .pressingPlay
            transportState = .restartPlay
        }
    }
    
    func stopButtonClicked() {
        if transportState == .defaultState {
            pressingStatus = .pressingStop
            transportState = .stopClicked
        }
        else if transportState == .playEngaged {
            pressingStatus = .pressingStop
            transportState = .stoppingPlay
        }
    }
    
    func mouseReleased() {
        if pressingStatus == .pressingPlay {
            transportMode  = .playing
            transportState = .playEngaged
            pressingStatus = .nonaction
        }
        else if pressingStatus == .pressingStop {
            transportMode  = .stopped
            transportState = .defaultState
            pressingStatus = .nonaction
        }
    }
    
    //    fileprivate func changeState(_ newState: TransportStatus) {
    //        transportState = newState
    //        updateView()
    //    }
    
    //    fileprivate func triggerModeChangeFrom(_ oldMode: RunningMode, to newMode: RunningMode) {
    //
    //        if newMode == .playing {
    //
    //            // send restart play command over callback
    //
    //            // printLog("TransportControlButtonView: didSet transportMode: newMode = Playing")
    //        }
    //
    //        else if newMode == .stopped {
    //
    //            if oldMode == .playing {
    //
    //                // send stop command over callback
    //
    //                // printLog("TransportControlButtonView: didSet transportMode: newMode = Stopped")
    //            }
    //        }
    //    }
}
