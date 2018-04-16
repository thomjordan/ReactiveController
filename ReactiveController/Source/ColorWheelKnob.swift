//
//  ColorWheelKnob.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/9/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


struct ColorWheelKnob : ComponentKind {
    
    let name: String! = "ColorWheelKnob"
    
    let kernelPrototype : KernelModelType? = ColorWheelKnobKernelModel()
}

extension ColorWheelKnob {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        let kernel = (model.kernel ?? ColorWheelKnobKernelModel()) as! ColorWheelKnobKernelModel
        
        let uiView = ColorWheelKnobUIView( kernel )
        
        model.kernel  = kernel
        model.reactor = ComponentReactorDefault( model )
        
        model.inputs.addNew(["STRINGCODE", "STRINGCODE", "STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                         model.reactor!.outputs,
                                                         kernel )
        
        //   model.reactor.establishOutputs = configOutputs( model.reactor!.outputs )
        
        model.reactor.uiView = uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: ColorWheelKnobKernelModel) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                // clean all inputs and outputs
                
                input.clean() ; output.clean()
                
                // now start redefining all inputs and outputs
                
         //       guard let outpin = output[0]?.pin.asStringCoder() else { return }
                
                
                input[0]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let _ = msg.intWithBound() {
                            
                            kernel.huePoint.value = msg
                        }
                    }
                }
                
                
                input[1]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let _ = msg.intWithBound() {
                            
                            kernel.widthRange.value = msg
                        }
                    }
                }
                
                
                input[2]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let _ = msg.intWithBound() {
                            
                            kernel.centerLevel.value = msg
                        }
                    }
                }
                
                // printLog("\(outpin)")
                
                /*
                proxyOutConnector1.pin = Connecter.newStringCoder()
                
                guard let proxyOutPin = proxyOutConnector1.pin.asStringCoder() else { return }
                
                output[0]?.connector.assign { (outpin) in
                    
                    proxyOutPin.bind(to: outpin)
                }
                
                 if let outpin = output[0]?.connector.pin.asStringCoder() {  // if real output already has the same type as now needed..
                 
                 proxyOutPin.bind(to: outpin)
                 }*/
                
            }
            
            input[0]?.setRefresh { reconfigProcess() }
            
            input[1]?.setRefresh { reconfigProcess() }
            
            input[2]?.setRefresh { reconfigProcess() }
        }
    }
    
}



final class ColorWheelKnobKernelModel : KernelModelType {
    
    var huePoint    : KernelParameter<StringCoder> = KernelParameter("huePoint", "")
    var widthRange  : KernelParameter<StringCoder> = KernelParameter("widthRange", "")
    var centerLevel : KernelParameter<StringCoder> = KernelParameter("centerLevel", "")
    
    required init() {
        self.huePoint    = KernelParameter("huePoint", "")
        self.widthRange  = KernelParameter("widthRange", "")
        self.centerLevel = KernelParameter("centerLevel", "")
        widthRange.value = EventsWriting.intPairAsBoundedInt(k: 127, x: 128)
    }
    
    func publish(to view: ComponentContentView) {
        huePoint.syncView(view)
        widthRange.syncView(view)
        centerLevel.syncView(view)
    }
    
    enum CodingKeys : String, CodingKey {
        case hue
        case wdth
        case cnter
    }
    
    required init(from decoder: Decoder) throws {
        
      //  super.init()
        
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        
        let h = try vals.decode( StringCoder.self, forKey: .hue )
        let w = try vals.decode( StringCoder.self, forKey: .wdth )
        let c = try vals.decode( StringCoder.self, forKey: .cnter )
        
        self.huePoint    = KernelParameter("huePoint", "")
        self.widthRange  = KernelParameter("widthRange", "")
        self.centerLevel = KernelParameter("centerLevel", "")
        
        huePoint.value    = h
        widthRange.value  = w
        centerLevel.value = c
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        
        let h : StringCoder = huePoint.value
        let w : StringCoder = widthRange.value
        let c : StringCoder = centerLevel.value
        
        try bin.encode( h, forKey: .hue )
        try bin.encode( w, forKey: .wdth )
        try bin.encode( c, forKey: .cnter )
    }
}



class ColorWheelKnobUIView : ComponentContentView {
    
    var kernel : ColorWheelKnobKernelModel!
    
    
    init(_ model: ColorWheelKnobKernelModel) {
        
        super.init(width: 90.0, height: 90.0)
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard let _huePoint    =    kernel.huePoint.value.intWithBound() else { return }
        guard let _widthRange  =  kernel.widthRange.value.intWithBound() else { return }
        guard let _centerLevel = kernel.centerLevel.value.intWithBound() else { return }
        
        let huePt = CGFloat(    _huePoint.k ) / CGFloat(    _huePoint.x )
        let width = CGFloat(  _widthRange.k ) / CGFloat(  _widthRange.x )
        let centr = CGFloat( _centerLevel.k ) / CGFloat( _centerLevel.x )
        
        ColorWheelKnobStyleKit.drawSizableKnob(knobScale:1.0, pointInRange:huePt, rangeWidth:width, centerOfRange:centr)
    }
    
}
