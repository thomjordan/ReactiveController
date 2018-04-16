//
//  Utils.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import AudioToolbox


// regex: \b[a-zA-Z][a-zA-Z0-9_]*\:
//   matches any token beginning with a letter and ending with a colon
//     with zero or more letters, numbers or underscores in between.


func getRandomColor() -> NSColor {
    let hue = ( Double( arc4random() % 256 ) / 256.0 )         //  0.0 to 1.0
    let sat = ( Double( arc4random() % 128 ) / 256.0 ) + 0.5   //  0.5 to 1.0, away from white
    let bri = ( Double( arc4random() % 128 ) / 256.0 ) + 0.5   //  0.5 to 1.0, away from black
    return NSColor(hue: CGFloat(hue), saturation: CGFloat(sat), brightness: CGFloat(bri), alpha: CGFloat(1.0))
}

func getRandomHueValue() -> CGFloat {
    return CGFloat( Double( arc4random() % 256 ) / 256.0 )
}

func getRandomSaturationValue() -> CGFloat {
    return CGFloat( Double( arc4random() % 158 ) / 256.0 ) + 0.617   //  0.383 to 1.0, away from white
}

func getRandomBrightnessValue() -> CGFloat {
    return CGFloat( Double( arc4random() % 158 ) / 256.0 ) + 0.617   //  0.383 to 1.0, away from black
}


func pmod(_ v:Int, modulus:Int) -> Int {     // variation of 'mod' where the modulus value replaces the result of 0 (e.g. pmod(24,12) -> 12)
    return ((v-1)%modulus)+1  //   result can be negative, if parameter v is negative
}

func signToBool(_ n:Int) -> Int { // positive numbers return 1, non-positive numbers (negative numbers and 0) return 0
    if (n > 0) {
        return 1
    } else {
        return 0
    }
}

func signToTrival(_ n:Int) -> Int {
    if (n > 0) {
        return 1
    } else if (n == 0) {
        return 0
    } else {
        return -1
    }
}

func boolNot(_ a:Int) -> Int {
    if a == 0 {
        return 1
    } else {
        return 0
    }
}


func pointOnCircle(_ center: NSPoint, polar: NSPoint) -> NSPoint {
    // polar.x is radius length, polar.y is angle in π radians
    let pi = CGFloat(3.14159265358979)
    let rads = polar.y * pi
    let px = CGFloat( cos( rads ))
    let py = CGFloat( sin( rads ))
    let p = NSPoint(x: center.x + ( polar.x * px ), y: center.y + ( polar.x * py ))
    return p
}


func calcSplitFrameVertical(_ frame: NSRect, lowerRatio: CGFloat = 0.5) -> (lower: NSRect, upper: NSRect) {
    
    let y = frame.origin.y
    
    let lowerHeight = frame.size.height * lowerRatio
    
    let upperHeight = frame.size.height - lowerHeight
    
    let lowerHalf = NSMakeRect(frame.origin.x, y, frame.size.width, lowerHeight)
    
    let upperHalf = NSMakeRect(frame.origin.x, y+lowerHeight, frame.size.width, upperHeight)
    
    return (lower: lowerHalf, upper: upperHalf)
}

func calcSplitFrameHorizontal(_ frame: NSRect, leftRatio: (Int, Int)) -> (left: NSRect, right: NSRect) {
    
    let originX     = frame.origin.x
    let originY     = frame.origin.y
    let width       = frame.size.width
    let height      = frame.size.height
    
    let numerator   = CGFloat( leftRatio.0 )
    let denominator = CGFloat( leftRatio.1 )
    
    let leftWidth   = (width * numerator) / denominator
    let rightWidth  = width - leftWidth
    let leftHalf    = NSMakeRect( originX, originY, leftWidth, height)
    let rightHalf   = NSMakeRect( originX + leftWidth, originY, rightWidth, height)
    
    return (left: leftHalf, right: rightHalf)
}



public func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

public func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    // return unsafeBitCast(ptr, T.self) // ***
}

public func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

public func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}


public func bpmToBeatInMs(_ bpm: Float64 = Constants.mainTempo) -> Int {
    let ms = 60000 / bpm
    return Int(ms)
}

public func bpmTo8thInMs(_ bpm: Float64 = Constants.mainTempo) -> Int {
    let ms = 60000 / bpm
    return Int(ms / 2.0)
}

public func bpmTo16thInMs(_ bpm: Float64 = Constants.mainTempo) -> Int {
    let ms = 60000 / bpm
    return Int(ms / 4.0)
}


// AudioToolbox error codes

public func confirm(_ err: OSStatus) {
    if err == 0 { return }
    
    switch(CInt(err)) {
        
    case kMIDIInvalidClient     :
        NSLog( "OSStatus error:  kMIDIInvalidClient ");
        
    case kMIDIInvalidPort       :
        NSLog( "OSStatus error:  kMIDIInvalidPort ");
        
    case kMIDIWrongEndpointType :
        NSLog( "OSStatus error:  kMIDIWrongEndpointType");
        
    case kMIDINoConnection      :
        NSLog( "OSStatus error:  kMIDINoConnection ");
        
    case kMIDIUnknownEndpoint   :
        NSLog( "OSStatus error:  kMIDIUnknownEndpoint ");
        
    case kMIDIUnknownProperty   :
        NSLog( "OSStatus error:  kMIDIUnknownProperty ");
        
    case kMIDIWrongPropertyType :
        NSLog( "OSStatus error:  kMIDIWrongPropertyType ");
        
    case kMIDINoCurrentSetup    :
        NSLog( "OSStatus error:  kMIDINoCurrentSetup ");
        
    case kMIDIMessageSendErr    :
        NSLog( "OSStatus error:  kMIDIMessageSendErr ");
        
    case kMIDIServerStartErr    :
        NSLog( "OSStatus error:  kMIDIServerStartErr ");
        
    case kMIDISetupFormatErr    :
        NSLog( "OSStatus error:  kMIDISetupFormatErr ");
        
    case kMIDIWrongThread       :
        NSLog( "OSStatus error:  kMIDIWrongThread ");
        
    case kMIDIObjectNotFound    :
        NSLog( "OSStatus error:  kMIDIObjectNotFound ");
        
    case kMIDIIDNotUnique       :
        NSLog( "OSStatus error:  kMIDIIDNotUnique ");
        
    case kAUGraphErr_NodeNotFound             :
        NSLog( "OSStatus error:  kAUGraphErr_NodeNotFound \n");
        
    case kAUGraphErr_OutputNodeErr            :
        NSLog( "OSStatus error:  kAUGraphErr_OutputNodeErr \n");
        
    case kAUGraphErr_InvalidConnection        :
        NSLog( "OSStatus error:  kAUGraphErr_InvalidConnection \n");
        
    case kAUGraphErr_CannotDoInCurrentContext :
        NSLog( "OSStatus error:  kAUGraphErr_CannotDoInCurrentContext \n");
        
    case kAUGraphErr_InvalidAudioUnit         :
        NSLog( "OSStatus error:  kAUGraphErr_InvalidAudioUnit \n");
        
    case kAudioToolboxErr_InvalidSequenceType :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidSequenceType ");
        
    case kAudioToolboxErr_TrackIndexError     :
        NSLog( "OSStatus error:  kAudioToolboxErr_TrackIndexError ");
        
    case kAudioToolboxErr_TrackNotFound       :
        NSLog( "OSStatus error:  kAudioToolboxErr_TrackNotFound ");
        
    case kAudioToolboxErr_EndOfTrack          :
        NSLog( "OSStatus error:  kAudioToolboxErr_EndOfTrack ");
        
    case kAudioToolboxErr_StartOfTrack        :
        NSLog( "OSStatus error:  kAudioToolboxErr_StartOfTrack ");
        
    case kAudioToolboxErr_IllegalTrackDestination :
        NSLog( "OSStatus error:  kAudioToolboxErr_IllegalTrackDestination");
        
    case kAudioToolboxErr_NoSequence           :
        NSLog( "OSStatus error:  kAudioToolboxErr_NoSequence ");
        
    case kAudioToolboxErr_InvalidEventType      :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidEventType");
        
    case kAudioToolboxErr_InvalidPlayerState  :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidPlayerState");
        
    case kAudioUnitErr_InvalidProperty          :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidProperty");
        
    case kAudioUnitErr_InvalidParameter          :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidParameter");
        
    case kAudioUnitErr_InvalidElement          :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidElement");
        
    case kAudioUnitErr_NoConnection              :
        NSLog( "OSStatus error:  kAudioUnitErr_NoConnection");
        
    case kAudioUnitErr_FailedInitialization      :
        NSLog( "OSStatus error:  kAudioUnitErr_FailedInitialization");
        
    case kAudioUnitErr_TooManyFramesToProcess :
        NSLog( "OSStatus error:  kAudioUnitErr_TooManyFramesToProcess");
        
    case kAudioUnitErr_InvalidFile              :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidFile");
        
    case kAudioUnitErr_FormatNotSupported      :
        NSLog( "OSStatus error:  kAudioUnitErr_FormatNotSupported");
        
    case kAudioUnitErr_Uninitialized          :
        NSLog( "OSStatus error:  kAudioUnitErr_Uninitialized");
        
    case kAudioUnitErr_InvalidScope           :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidScope");
        
    case kAudioUnitErr_PropertyNotWritable      :
        NSLog( "OSStatus error:  kAudioUnitErr_PropertyNotWritable");
        
    case kAudioUnitErr_InvalidPropertyValue      :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidPropertyValue");
        
    case kAudioUnitErr_PropertyNotInUse          :
        NSLog( "OSStatus error:  kAudioUnitErr_PropertyNotInUse");
        
    case kAudioUnitErr_Initialized              :
        NSLog( "OSStatus error:  kAudioUnitErr_Initialized");
        
    case kAudioUnitErr_InvalidOfflineRender      :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidOfflineRender");
        
    case kAudioUnitErr_Unauthorized              :
        NSLog( "OSStatus error:  kAudioUnitErr_Unauthorized");
        
    default :
        NSLog("OSStatus error:  unrecognized type: %d", err)
    }
}

