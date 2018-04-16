//
//  MidiSourceProcessor.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/24/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//



import Cocoa
import ReactiveKit




// MARK: - MidiSourceProcessor


class MidiSourceProcessor : ComponentProcessor {
    
    let midiCenter = MidiCenter.sharedMidiCenter
    
    let midiIn       = Property(MidiNodeMessage())
    
    var incomingMidi = Property(MidiNodeMessage())
    
    // Eventually 'sourceSpecificMidi' should be changed to a ConnectorPin wrapper, along with the 'source' var used within the StandardOutputRoutine,
    //  so Components may choose to accept or deploy CollectionPropertys, Operations and/or Propertys, and not limited to use of the latter only.
    
    var sourceSpecificMidi = Property(VVMIDIMessage())
    
    var output1 : ConnectionPoint?
    
    var output2 : ConnectionPoint?
    
    var output3 : ConnectionPoint?
    
    var output4 : ConnectionPoint?
    
    
    var output1Routine : MidiNoteSourceRoutine!
    
    var output2Routine : MidiVelocityOutputRoutine!
    
    var output3Routine : MidiCCOutputRoutine!
    
    var output4Routine : MidiSourceOutputRoutine!
    
    // for housekeeping
    
    var newSignal  : Property<MidiNodeMessage>?
    
    
    
    var devicePredicate  : (String) -> Bool = { _ in true } {
        
        didSet {
            
            establishOutputConfigurations()
            
            updatePredicatesAndRebindSourceSpecificMidiProperty()
        }
        
    }
    
    var channelPredicate :  (UInt8) -> Bool = { _ in true } {
        
        didSet {
            
            establishOutputConfigurations()
            
            updatePredicatesAndRebindSourceSpecificMidiProperty()
        }
        
    }
    
    
    override init(mediator: ComponentMediator) {
        
        super.init(mediator: mediator)
        
        output1 = self[.output, 0]
        
        output2 = self[.output, 1]
        
        output3 = self[.output, 2]
        
        output4 = self[.output, 3]
        
        
        establishCallbacks()
        
        updatePredicatesAndRebindSourceSpecificMidiProperty()
        
        establishOutputConfigurations()
        
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    func startReceivingMidi() -> Operation {
        
        return Operation { observer in
            
            self.midiCenter.addMidiReceiveCallback {
                
                (msg:MidiNodeMessage) in observer.next( msg )  
            }
            
           return NotDisposable
        }
    }
    
    
    func establishCallbacks() {
        
        midiCenter.addMidiReceiveCallback {
            
            [weak self] (msg:MidiNodeMessage) in if let s = self { s.incomingMidi.value = msg } //; printLog("MIDI msg received..")}
        }
        
    }
    
    
    
    func updatePredicatesAndRebindSourceSpecificMidiProperty() {
        
        disposeDisposables()
        
        let disp = incomingMidi
            
            .filter  { msg in self.devicePredicate( msg.node ) }  // [unowned self]
            
            .filter  { msg in self.channelPredicate( msg.midi.channel() ) }  // [unowned self]
            
            .observeNext { msg in  // [unowned self]
                
                self.sourceSpecificMidi.value = msg.midi  // see declaration of sourceSpecificMidi at the top of page for important information..
                
                if msg.midi.lengthyDescription() != nil {
                    
                    printLog(msg.node + ": " + msg.midi.lengthyDescription() )
                    
                }
        }
        
        stashDisposable( disp )
        
        
    }
    
    // ["notes+vel":["IntValue","CCIntPair"],"notes":["IntValue"], "velocity":["IntValue"],"controllers":["CCIntPair"]]
    
    
    
    override func establishOutputConfigurations() {
        
        guard let output1 = self.output1 as? OutputPoint else { printLog("MidiSource output1 guard failed.") ; return }
        
        guard let output2 = self.output2 as? OutputPoint else { printLog("MidiSource output2 guard failed.") ; return }
        
        guard let output3 = self.output3 as? OutputPoint else { printLog("MidiSource output3 guard failed.") ; return }
        
        guard let output4 = self.output4 as? OutputPoint else { printLog("MidiSource output4 guard failed.") ; return }
        
        
        self.output1Routine = MidiNoteSourceRoutine(source: sourceSpecificMidi, output: output1)
        
        self.output2Routine = MidiVelocityOutputRoutine(source: sourceSpecificMidi, output: output2)
        
        self.output3Routine = MidiCCOutputRoutine(source: sourceSpecificMidi, output: output3)
        
        self.output4Routine = MidiSourceOutputRoutine(source: sourceSpecificMidi, output: output4)
        
        
        output1.resetConfiguration = { self.output1Routine.performRoutine() }
        
        output2.resetConfiguration = { self.output2Routine.performRoutine() }
        
        output3.resetConfiguration = { self.output3Routine.performRoutine() }
        
        output4.resetConfiguration = { self.output4Routine.performRoutine() }
        
        
        output3.outputTask = {   // set output signal task for runtime dynamic attachment
            
            CCFilter( args: [ LabeledAttributeParameter(label: "ccnum == ", param: .newIntBind("16")) ] )
        
        }
    }
    

    
    
    func makeDevicePredicate(_ selectedName: String) {
        
        var predicate : (String) -> Bool
        
        let name = removeAnySpacesInText(selectedName)
        
        if name != "" && name != "globalmidiin" {
            
            predicate = { ( nodename : String ) in nodename == selectedName }
            
            devicePredicate = predicate
        }
            
        else {
            
            //printLog("device name: \(name)")
            
            predicate = { ( _ : String ) in true }
            
            devicePredicate = predicate
        }
        
    }
    
    
    
    func makeChannelPredicate(_ selectedChannel: String) {
        
        var predicate : (UInt8) -> Bool
        
        let channel = removeAnySpacesInText(selectedChannel)
        
        if channel != "" && channel != "all" {
            
            if let channelNumber = UInt8(channel) {
                
                predicate = { ( chan : UInt8 ) in chan == channelNumber }
                
                channelPredicate = predicate
                
                return
            }
            
        }
        
        //printLog("channel: \(channel)")
        
        predicate = { ( _ : UInt8 ) in true }
        
        channelPredicate = predicate
    }
    
    func removeAnySpacesInText(_ text: String) -> String {
        
        return text.replacingOccurrences(of: " ", with: "")
        
    }
    
}



