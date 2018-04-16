//
//  EventsTypes.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/18/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit
import MidiPlex

typealias StringCoder = String

// --------------------------------------------------------------------------------
//  MARK: - Event Prototypes
// --------------------------------------------------------------------------------

// NoteVelocityPair  :  "n: 38; v: 96; "
// CCValuePair       :  "cc: 16; cv: 79; "
// BoundedInt        :  "k: 11; x: 128; "
// BoundedIntList    :  "steps: 0, 1, 2, 3, ..., 15; x: 16; "

// --------------------------------------------------------------------------------
//  MARK: - EventsWriting
// --------------------------------------------------------------------------------


public func constrainRange(_ val: Int, _ bound: Int = 128) -> Int {
    let limit = bound <= 0 ? 16 : bound
    let result = val < 0 ? 0 : (val < limit ? val : limit-1)
    return result
}


public enum EventsWriting {
    
    public static func intPairAsBoundedInt(k: Int, x: Int) -> String {
        let result : String = "k: \(k); x: \(x); "
        return result
    }
    
    public static func intStepsWithBound(steps: [Int], x: Int) -> String {
        let result : String = "steps: \(steps.asString); x: \(x); "
        return result
    }
    
    public static func intPairToNNumVelPair(n: Int, v: Int) -> String {
        let result = "n: \(n); v: \(v); "
        return result
    }
    
    public static func midiMsgToNNumVelPair(msg: MidiMessage) -> String? {
        guard msg.isNoteOn() || msg.isNoteOff() else { return nil }
        let result = "n: \(msg.data1()); v: \(msg.data2()); "
        return result
    }
    
    public static func midiMsgToNNumVelChan(msg: MidiMessage) -> String? {
        guard msg.isNoteOn() || msg.isNoteOff() else { return nil }
        let result = "n: \(msg.data1()); v: \(msg.data2()); ch: \(msg.channel()); "
        return result
    }
    
    public static func midiMsgToCNumValPair(msg: MidiMessage) -> String? {
        guard msg.isControlChange() else { return nil }
        let result = "cc: \(msg.data1()); cv: \(msg.data2()); "
        return result
    }
    
    public static func midiMsgToCNumValChan(msg: MidiMessage) -> String? {
        guard msg.isControlChange() else { return nil }
        let result = "cc: \(msg.data1()); cv: \(msg.data2()); ch: \(msg.channel()); "
        return result
    }
}

// --------------------------------------------------------------------------------
//  MARK: - StringCoder - Events reading
// --------------------------------------------------------------------------------

extension StringCoder {
    
    public func intPairNoteVel() -> (n: Int, v: Int)? {
        let temp = EventsReading.intPairMatching("n", "v", in: self)
        guard let result = temp else { return nil }
        return (n: result.0, v: result.1)
    }
    
    public func intPairCtrlVal() -> (cc: Int, cv: Int)? {
        let temp = EventsReading.intPairMatching("cc", "cv", in: self)
        guard let result = temp else { return nil }
        return (cc: result.0, cv: result.1)
    }
    
    public func intSingleCtrlVal() -> Int? {
        let temp = EventsReading.intSingleMatching("cv", in: self)
        guard let result = temp else { return nil }
        return result
    }
    
    public func intWithBound() -> (k: Int, x: Int)? {
        let temp = EventsReading.intPairMatching("k", "x", in: self)
        guard let result = temp else { return nil }
        return (k: result.0, x: result.1)
    }
    
    // intTripleMatching
    
    public func intWithBoundInTrack() -> (k: Int, x: Int, track: Int)? {
        let temp = EventsReading.intTripleMatching("k", "x", "track", in: self)
        guard let result = temp else { return nil }
        return (k: result.0, x: result.1, track: result.2)
    }
    
    public func intStepsListWithBound() -> (steps: [Int], x: Int)? {
        let temp = EventsReading.intArrayWithIntMatching("steps", "x", in: self)
        guard let result = temp else { return nil }
        return (steps: result.0, x: result.1)
    }
    
    // --------------------------------------------------------------------------------
    
    public func intMatching(_ key: String) -> Int? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Int($0) } : nil
        guard let result = temp2 else { return nil }
        guard result.count == 1 else { return nil }
        return result[0]
    }
    
    public func intsMatching(_ key: String) -> [Int]? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Int($0) } : nil
        return temp2
    }
    
    public func floatMatching(_ key: String) -> Float? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Float($0) } : nil
        guard let result = temp2 else { return nil }
        guard result.count == 1 else { return nil }
        return result[0]
    }
    
    public func floatsMatching(_ key: String) -> [Float]? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Float($0) } : nil
        return temp2
    }
    
    public func timestampMatching(_ key: String) -> Float64? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Float64($0) } : nil
        guard let result = temp2 else { return nil }
        guard result.count == 1 else { return nil }
        return result[0]
    }
    
    public func timestampsMatching(_ key: String) -> [Float64]? {
        let temp1 = EventsReading.getEntryMatching(key, in: self)
        let temp2 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Float64($0) } : nil
        return temp2
    }
}


// --------------------------------------------------------------------------------
//  MARK: - EventsReading : helper functions
// --------------------------------------------------------------------------------

enum EventsReading {
    
    fileprivate static func parseInput(_ str: String) -> [[String]] {
        let temp = (str.split(separator: ";").map { $0.split(separator: ":")  })
        var dictArray : [[String]] = []
        for arr in temp {
            if arr.count == 2 {
                let theKey = String(arr[0]).trimmingCharacters(in: .whitespaces)
                let theVal = String(arr[1]).components(separatedBy: .whitespaces).joined()
                dictArray.append( [theKey, theVal] )
            }
        }
        return dictArray
    }
    
    fileprivate static func getEntryMatching(_ key: String, in arry: String) -> String? {
        var result : String? = nil
        let arr = parseInput(arry)
        for a in arr { if a.count == 2 && a[0] == key { result = a[1]; break } }
        return result
    }
    
    fileprivate static func getEntryMatching(_ key: String, in arr: [[String]]) -> String? {
        var result : String? = nil
        for a in arr { if a.count == 2 && a[0] == key { result = a[1]; break } }
        return result
    }
    
    // refactor by decomposing the following four methods into standalone parameter/matcher constructs expressed as:
    //   individual types/cases within a generically-defined recursive ADT structure (e.g. uses type-parameters)
    //  e.g. instead of defining a separate method for each required combination of types and arity,
    //    each part of the requested signature is produced by constructing its corresponding type-case within the recursive ADT,
    //    and subsequently, each requested combination of types (e.g. intPair, intTriple, intArrayWithInt, etc.) is built up
    //    from recursing over the ADT, adding new cases until the requested arity and type combination is produced.
    //
    // Thus, a method such as "intPairNoteVel" will define the exact assemblage of cases it requires
    //   as a reified instantiation of the recursive ADT, instead of calling an over-specified function such as:
    //     EventsReading.intPairMatching("n", "v", in: self)
    
    fileprivate static func intSingleMatching(_ key: String, in arry: String) -> Int? {
        let arr = parseInput(arry)
        let temp = getEntryMatching(key, in: arr)
        let r = temp != nil ? temp!.components(separatedBy: ",").flatMap { Int($0) } : nil
        guard let result = r else { return nil }
        guard result.count == 1 else { return nil }
        return result[0]
    }
    
    fileprivate static func intPairMatching(_ key1: String, _ key2: String, in arry: String) -> (Int, Int)? {
        let arr = parseInput(arry)
        let temp1 = getEntryMatching(key1, in: arr)
        let temp2 = getEntryMatching(key2, in: arr)
        let r1 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Int($0) } : nil
        let r2 = temp2 != nil ? temp2!.components(separatedBy: ",").flatMap { Int($0) } : nil
        guard let result1 = r1, let result2 = r2 else { return nil }
        guard result1.count == 1 && result2.count == 1 else { return nil }
        return (result1[0], result2[0])
    }
    
    fileprivate static func intArrayWithIntMatching(_ key1: String, _ key2: String, in arry: String) -> ([Int], Int)? {
        let arr = parseInput(arry)
        let temp1 = getEntryMatching(key1, in: arr)
        let temp2 = getEntryMatching(key2, in: arr)
        let r1 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Int($0) } : nil
        let r2 = temp2 != nil ? temp2!.components(separatedBy: ",").flatMap { Int($0) } : nil
        guard let result1 = r1, let result2 = r2 else { return nil }
        guard result1.count >= 1 && result2.count == 1 else { return nil }
        return (result1, result2[0])
    }
    
    fileprivate static func intTripleMatching(_ key1: String, _ key2: String, _ key3: String, in arry: String) -> (Int, Int, Int)? {
        let arr = parseInput(arry)
        let temp1 = getEntryMatching(key1, in: arr)
        let temp2 = getEntryMatching(key2, in: arr)
        let temp3 = getEntryMatching(key3, in: arr)
        let r1 = temp1 != nil ? temp1!.components(separatedBy: ",").flatMap { Int($0) } : nil
        let r2 = temp2 != nil ? temp2!.components(separatedBy: ",").flatMap { Int($0) } : nil
        let r3 = temp3 != nil ? temp3!.components(separatedBy: ",").flatMap { Int($0) } : nil
        guard let result1 = r1, let result2 = r2, let result3 = r3 else { return nil }
        guard result1.count == 1 && result2.count == 1 && result3.count == 1 else { return nil }
        return (result1[0], result2[0], result3[0])
    }
}

// Example usage:

//let input     = "vals: 98 ,99 , 97, 96, 91.2, 98.6, 30; k: 21; n: 128; "
//let eventVals = getTimestampsMatching("vals", in: input)

// -----------------------------------------------------------------------------------------------------------------
// ~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~$~
// -----------------------------------------------------------------------------------------------------------------

