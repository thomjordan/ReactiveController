//
//  FreeFunctions.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
// ♭ ♯  ♮  𝄫 𝄪

func getComponentKind(of name: String) -> ComponentKind? {
    
    let dict : [String : ComponentKind] = [ "MidiSource"    : MidiSource(),
                                            "BezierKnob"    : BezierKnob(),
                                            "ColorWheelKnob": ColorWheelKnob(),
                                            "TriggerPlayer" : TriggerPlayer(),
                                            "StepPattern"   : StepPattern(),
                                            "Keyscale"      : Keyscale(),
                                            "BinarySpacePad": BinarySpacePad(),
                                            "BufferPlayer"  : BufferPlayer(),
                                            "MidiOutput"    : MidiOutput(), 
                                            "CodeBox"       : CodeBox() ] //,
                                           // "KeyscaleJS"    : KeyscaleJS() ] //, //,
                                           // "BezierKnobJS"  : BezierKnobJS(1) ]
    
    let result = dict[ name ]
    
    return result
}

/*  BOILERPLATE for CODABLE
 
enum CodingKeys : String, CodingKey {
    case keyA
    case keyB
}

required init(from decoder: Decoder) throws {
    let vals = try decoder.container(keyedBy: CodingKeys.self)
    // _ = try vals.decode( , forKey: )
}

func encode(to encoder: Encoder) throws {
    var bin = encoder.container(keyedBy: CodingKeys.self)
    // try bin.encode( , forKey: )
}
*/
 
