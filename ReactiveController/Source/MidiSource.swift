//
//  MidiSource.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiPlex 


struct MidiSource : ComponentKind {
    
    let name: String! = "MidiSource"
    
    let kernelPrototype : KernelModelType? = MidiSourceKernelModel()
}


extension MidiSource {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        let kernel = (model.kernel ?? MidiSourceKernelModel()) as! MidiSourceKernelModel

        let reactor = MidiSourceComponentReactor( model )
        reactor.establishCallbacks()
        
        model.kernel  = kernel
        model.reactor = reactor
        
        let uiView = MidiSourceUIView( kernel, reactor )
        
        model.outputs.addNew(["STRINGCODE", "STRINGCODE", "MIDIMESSAGE"])
        
        model.reactor.establishProcess = configProcess( reactor, kernel )
        
        //   model.reactor.establishOutputs = configOutputs( model.reactor!.outputs )
        
        model.reactor.uiView = uiView
        
        uiView.setupObserverForDeviceSelection()
        
        uiView.setMidiDeviceMenuToModelValue()
        
        model.reactor.observeSelectionStatus()
    }
    
 
    
    private func configProcess(_ reactor: MidiSourceComponentReactor,
                               _ kernel:  MidiSourceKernelModel       ) -> () -> () {
        
        return {
            
            reactor.updatePredicatesAndRebindSourceSpecificMidiProperty()
            
            
            reactor.outputs[0]?.setRefresh {
                
                MidiNoteSourceRoutine(source: reactor.sourceSpecificMidi,
                                      output: reactor.outputs[0]).performRoutine()
                
            }
            
            reactor.outputs[1]?.setRefresh {
                
                MidiCCOutputRoutine(source: reactor.sourceSpecificMidi,
                                    output: reactor.outputs[1]).performRoutine()
                
            }
            
            reactor.outputs[2]?.setRefresh {
                
                MidiSourceOutputRoutine(source: reactor.sourceSpecificMidi,
                                        output: reactor.outputs[2]).performRoutine()
                
            }
            
            
            reactor.outputs[1]?.outputTask = {   // set output signal task for runtime dynamic attachment
                
                CCFilter( args: [ ParameterProperty("cc", .newIntValue("16")) ] )
                
            }
            
            reactor.updatePredicatesAndRebindSourceSpecificMidiProperty()
            
        }
 
    }
}


final class MidiSourceKernelModel : KernelModelType { // }, Codable {
    
    var selectedSource : Property<String> = Property("")
    
    func publish(to view: ComponentContentView) {
        // try to refactor some of the surrounding functionality into this method if possible
        // _.syncView( view )
    }
    
    required init() {
      //  super.init()
        self.selectedSource = Property("")
    }
    
    enum CodingKeys : String, CodingKey {
        case source
    }
    
    required init(from decoder: Decoder) throws {
      //  super.init()
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedSource = Property("")
        selectedSource.value = try vals.decode( String.self, forKey: .source )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( selectedSource.value, forKey: .source )
    }
    
}



final class MidiSourceComponentReactor : ComponentReactor {
    
    var bags = DisposeBagStore()
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    
    var incomingMidi = Property(MidiNodeMessage())
    
    var sourceSpecificMidi = Property(MidiMessage())
    
    
    var devicePredicate  : (String) -> Bool = { _ in true } {
        
        didSet { establishProcess?() }
    }
    
    var channelPredicate :  (UInt8) -> Bool = { _ in true } {
        
        didSet { establishProcess?() }
        
    }

    
    init() { }
    
    func close() { disposeAll() }
    
    
    func makeDevicePredicate(_ selectedName: String) {
        
        var predicate : (String) -> Bool
        
        let name = removeAnySpacesInText(selectedName)
        
        if name != "" && name != "globalmidiin" {
            
            predicate = { ( nodename : String ) in nodename == selectedName }
            
            devicePredicate = predicate
        }
            
        else {
            
            //// printLog("device name: \(name)")
            
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
        
        //// printLog("channel: \(channel)")
        
        predicate = { ( _ : UInt8 ) in true }
        
        channelPredicate = predicate
    }
    
    func removeAnySpacesInText(_ text: String) -> String {
        
        return text.replacingOccurrences(of: " ", with: "")
        
    }
    
    
    func establishCallbacks() {
        
        MidiCenter.shared
            
            .addMidiReceiveCallback { [weak self] (msg:MidiNodeMessage) in
                
                if let s = self { s.incomingMidi.value = msg }
                
                // printLog("MIDI msg received..")
            }
    }
    
    
    func updatePredicatesAndRebindSourceSpecificMidiProperty() {
        
        guard let msParams = bags.makeNew("MidiSourceParams") else { return }
        
        incomingMidi
            
            .filter  { msg in self.devicePredicate( msg.node ) }  // [unowned self]
            
            .filter  { msg in self.channelPredicate( msg.midi.channel() ) }  // [unowned self]
            
            
            .observeNext { msg in  // [unowned self]
                
                self.sourceSpecificMidi.value = msg.midi  // see declaration of sourceSpecificMidi at the top of page for important information..
                
                if msg.midi.lengthyDescription() != nil {
                    
                    // printLog(msg.node + ": " + msg.midi.lengthyDescription() )
                    
                }
                
            }.dispose(in: msParams)
    }
    
//    func initMidiSourceParamsObserverBag() -> DisposeBag? { return bags.makeNew("MidiSourceParams") }
}


// MARK: - MidiSourceUIView

class MidiSourceUIView : ComponentContentView {
    
    weak var kernel  : MidiSourceKernelModel!
    weak var reactor : MidiSourceComponentReactor!
    
    
    static var channelMenuItems:[String] { return ["all"] + [Int](1...16).map { String($0) } }
    
    var devicesMenu = CustomPopUpButton(frame: NSMakeRect(   0, 13, 120, 17 ))
    
    var channelMenu = CustomPopUpButton(frame: NSMakeRect( 125, 13,  35, 17 ))
    
    
    var devices: [String] = ["", "Wireless MIDI", "IAC Bus 1", "IAC Bus 2"]
    
    var channel: [String] = MidiSourceUIView.channelMenuItems { didSet { self.channel = MidiSourceUIView.channelMenuItems } }
    
    
    var selectedDevice  : String? = ""
    
    var selectedChannel : String? = ""
    
    
    
    init(_ model: MidiSourceKernelModel, _ actor: MidiSourceComponentReactor) {
        
        super.init(width: 160.0, height: 32.0)

        self.kernel  = model
        self.reactor = actor

        if let dvcell = devicesMenu.cell as? NSPopUpButtonCell {
            
            dvcell.arrowPosition = .noArrow
            
            dvcell.alignment     = .center
            
            dvcell.isBordered    = false
            
            dvcell.font          = NSFont.menuBarFont(ofSize: 10)
            
            dvcell.bezelStyle    = NSButton.BezelStyle.regularSquare
            
            dvcell.cellAttribute(.changeGrayCell)
        }
        
        if let chcell = channelMenu.cell as? NSPopUpButtonCell {
            
            chcell.image = NSImage.swatchWithColor( textCellBGColor, size: channelMenu.frame.size )
            
            chcell.arrowPosition = .noArrow
            
            chcell.alignment     = .center
            
            chcell.isBordered    = false
            
            chcell.font          = NSFont.menuBarFont(ofSize: 10)
            
            chcell.bezelStyle    = NSButton.BezelStyle.regularSquare
            
            chcell.cellAttribute(.changeGrayCell)
        }
        
        
        channelMenu.image = NSImage.swatchWithColor( textCellBGColor, size: channelMenu.frame.size )
        
        
        
        updateMidiSourceDeviceMenu()
        
        updateMidiSourceChannelMenu()
        
        
        self.addSubview(devicesMenu)
        
        self.addSubview(channelMenu)
        
        
        updateMenuViews() 
        
        
        devicesMenu.action = #selector(MidiSourceUIView.registerNewDeviceSelection(_:))
        
        channelMenu.action = #selector(MidiSourceUIView.registerNewChannelSelection(_:))
        
        devicesMenu.target = self
        
        channelMenu.target = self
    }
    
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
    }
    
    func updateMenuViews() {
        DispatchQueue.main.async { [weak self] in
            self?.devicesMenu.needsDisplay = true
            self?.channelMenu.needsDisplay = true
        }
    }
    
    
    func updateMidiSourceDeviceMenu() {
        
        devices = ["global midi in"] + MidiCenter.shared.midiSourceNames
        
        devicesMenu.removeAllItems()
        
        let font : NSFont = getValidFont(11)
        
        for str in devices {
            
            let item = NSMenuItem()
            
            item.attributedTitle = NSAttributedString( string: str, attributes:[NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: textCellTextColor ] )
            
            devicesMenu.menu?.addItem( item )
            
        }
        
    }
    
    
    func updateMidiSourceChannelMenu() {
        
        channelMenu.removeAllItems()
        
        let font : NSFont = getValidFont(11)
        
        for str in channel {
            
            let item = NSMenuItem()
            
            item.attributedTitle = NSAttributedString( string: str, attributes:[NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: textCellTextColor ] )
            
            channelMenu.menu?.addItem( item )
        }
        
    }
    
    
    @objc func registerNewDeviceSelection(_ sender: AnyObject) {
        
        // printLog("MidiSourceUIView: registerNewDeviceSelection()")
        
        if let s = sender as? CustomPopUpButton {
            
            selectedDevice = s.titleOfSelectedItem
            
            if let deviceName = s.titleOfSelectedItem {
                
                kernel.selectedSource.value = deviceName
            }
        }
    }
    
    
    func setupObserverForDeviceSelection() {
        
        kernel.selectedSource
            
            .observeNext { [weak self] deviceName in
                
                self?.reactor.makeDevicePredicate( deviceName )
                
                self?.devicesMenu.setTitle(deviceName)
                    
                // printLog("New device selection has been made: \( deviceName )")
        
            }.dispose(in: bag)
    }
    
    func setMidiDeviceMenuToModelValue() {
        
        let deviceNameInModel = kernel.selectedSource.value
        
        kernel.selectedSource.value = deviceNameInModel
        
        // set current view setting to match value in model
        
        //  devicesMenu.setTitle(unitModel.selectedSource.value)
        
        //  updateMenuViews()
        
        // add token

    }
    
    
    @objc func registerNewChannelSelection(_ sender: AnyObject) {
        
        // printLog("MidiSourceUIView: registerNewChannelSelection()")
        
        if let s = sender as? NSPopUpButton {
            
            selectedChannel = s.titleOfSelectedItem
            
            guard let channel = selectedChannel else { return }
            
            reactor.makeChannelPredicate( channel )
            
            // printLog("New channel selection has been made: \( channel )")
        }
    }
}





// MARK: - CustomPopUpButton

class CustomPopUpButton : NSPopUpButton {
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        NSColor(calibratedRed: 0.255, green: 0.266, blue: 0.314, alpha: 1).set()
        
        //Colors.uiComponentInterfaceBackground.set()
        
        self.wantsLayer             = true
        
        self.layer?.frame           = self.frame
        
        self.layer?.cornerRadius    = 5.0
        
        self.layer?.masksToBounds   = true
        
        
        //let outline = NSBezierPath(roundedRect: bounds, xRadius: 6.0, yRadius: 6.0)
        
        // NSRectFill(bounds)
        NSDrawButton(bounds, bounds) 
        
        //cell?.draw(withFrame: bounds, in: self)
        
        guard let theCell = cell else { return }
        
        theCell.draw(withFrame: bounds, in: self)
    }
}


