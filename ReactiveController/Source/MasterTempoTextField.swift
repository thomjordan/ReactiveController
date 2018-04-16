//
//  MasterTempoTextField.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/5/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit


class MasterTempoTextField : NSTextField {
    
    weak var model : MasterTempoBarBeatModel?
    
    var observerToken : Disposable?
    
    var latestValidText : String = "120.00"
    
    
    init(frame: NSRect, model: MasterTempoBarBeatModel) {
        
        super.init(frame: frame)
        
        formatter = TempoBoxFormatter()
        
        font = NSFont.boldSystemFont(ofSize: 10)
        
        self.model = model
        
        startObserving()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    deinit { observerToken?.dispose() }
    
    
    override func textDidChange(_ notification: Notification) {
        
        super.textDidChange(notification)
        
        printLog("MasterTempoTextField: text did change.")
    }
    
    
    
    override func textDidEndEditing(_ notification: Notification) {
        
        guard let currVal = model?.masterTempo.value else { return }
        
        let results = validateDecimalValue()
        
        if results.isValid {
            
            model?.masterTempo.value = Float64(results.theValue)
        }
            
        else { model?.masterTempo.value = currVal }
        
    }
    
    
    fileprivate func startObserving() {

        observerToken = model?.masterTempo
            .executeOn(.global(qos: .userInteractive))
            .observeOn(.main)
            .observeNext { tempo in
                let text             = String(describing: tempo)
                self.stringValue     = text
                self.latestValidText = text
            }
    }
    
    fileprivate func validateDecimalValue() -> (isValid: Bool, theValue: CGFloat) {
        
        var result : Double = 0
        
        var allnums = true
        
        var hasDecimalPoint = false
        
        let chars = self.stringValue
        
        for chr in chars.characters {
            if (chr >= "0" && chr <= "9") {
                allnums = allnums && true
            } else if (chr == ".") {
                if !hasDecimalPoint { allnums = allnums && true }
                else { allnums = allnums && false }
                hasDecimalPoint = true
            } else {
                allnums = allnums && false
            }
        }
        
        if allnums { result = Double(stringValue)! }
        
        return (isValid: allnums, theValue: CGFloat(result))
    }
    
}



class TempoBoxFormatter : NumberFormatter {
    
    override init() {
        super.init()
        numberStyle = NumberFormatter.Style.decimal
        allowsFloats = true
        minimumFractionDigits = 2
        maximumFractionDigits = 2
        minimum = 20.00
        maximum = 499.99
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?, errorDescription error: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?) -> Bool {
        if (partialString.utf16.count==0) {
            return true
        }
        
        if (partialString.rangeOfCharacter(from: CharacterSet(charactersIn:".0123456789").inverted) != nil) {
            // NSBeep()
            return false
        }
        
        return true
    }
}

