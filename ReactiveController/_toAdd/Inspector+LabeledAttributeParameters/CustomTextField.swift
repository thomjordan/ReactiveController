//
//  CustomTextField.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/31/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit


class CustomTextField : NSTextField {
    
    var suggestedFont : NSFont?
    
    var textValue : String {
        
        get { return self.stringValue }
        
        set(newValue) {
            
            var font : NSFont = NSFont.messageFont(ofSize: 11)
            
            if let _ = self.suggestedFont { font = self.suggestedFont! }
            
            let textColor = NSColor.white
            
            let str = NSAttributedString( string: newValue, attributes:[NSFontAttributeName: font, NSForegroundColorAttributeName: textColor ] )
            
            self.attributedStringValue = str
        }
        
    }
    
    //var datastore: Property<String?>? { didSet { makeBinding() } }
    
    
    
    init(frame: NSRect, text: String = "", color: NSColor = NSColor.darkGray, font: NSFont? = NSFont(name: "Avenir-Heavy", size: 13), bordered: Bool = false, alignment:NSTextAlignment = NSTextAlignment.natural, editing: Bool = false ) {
        
        super.init(frame: frame)
        
        self.suggestedFont = font
        
        self.textValue = text
        
        //self.datastore = datastore
        
        if let txtcell = self.cell as? NSTextFieldCell {
            
            txtcell.backgroundColor = color
            
            txtcell.alignment       = .natural
            
            txtcell.isBordered        = bordered
            
            txtcell.isEditable        = editing
            
            txtcell.cellAttribute(.changeGrayCell)
        }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    func makeReciprocalBinding( _ bindee: Property<String?> ) {
        
        self.rText.bindTo( bindee )
        
        bindee.bindTo( self.rText )
    }
    
}






















