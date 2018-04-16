//
//  AttributesPanelArchitectler.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/29/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit
import Neon


enum ControlView {
    
    case text( NSTextField )
    
    case toggle( NSButton )
    
    
    func isText() -> NSTextField? {
        
        if case let .text( cview ) = self { return cview }
            
        else { return nil }
    }
    
    func isToggle() -> NSButton? {
        
        if case let .toggle( cview ) = self { return cview }
            
        else { return nil }
    }
    
    func attachControl( _ task: (NSControl) -> () ) {
        
        let mText = self.isText()
        
        let mToggle = self.isToggle()

        if let tf = mText   { task( tf ) }
            
        if let tg = mToggle { task( tg ) }
    }
    
    func prepareView(_ color : NSColor) -> NSView {
        
        var result = NSView()
        
        let mText = self.isText()
        
        let mToggle = self.isToggle()
        
        if let tf = mText   {
            
            tf.backgroundColor = color
            
            result = tf
        }
        
        if let tg = mToggle {
            
            let zeroedFrame = NSMakeRect( 0, 0, tg.frame.size.width, tg.frame.size.height)
            
            let temp = NSView(frame: tg.frame)
            
            let background = NSTextField(frame: zeroedFrame)
            
            tg.frame = zeroedFrame
            
            background.isEditable  = false
            
            background.isBordered  = false
            
            background.isBezeled   = false
            
            background.backgroundColor = color
            
            temp.addSubview(background)
            
            temp.addSubview(tg)
            
            result = temp
        }
        
        return result
    }
    
    func determineSizeOfControl(_ ratio: CGFloat) -> CGFloat {
        
        var result = ratio
        
        let mText = self.isText()
        
        let mToggle = self.isToggle()
        
        if let _ = mText   { result = ratio }
        
        if let _ = mToggle { result = ( 1 - ratio ) }
        
        return result
    }
    
}


@objc class AttributesPanelArchitect : NSObject {
    
    typealias StringAttributes = ( font: NSFont?, size: CGFloat, color: NSColor )
    
    let notifications = NotificationCenter.default 
    
    var wrapper : NSBox!
    
    var rowViews: [NSView] = []
    
    var width   : CGFloat!
    
    var height  : CGFloat!
    
    var ratio   : CGFloat!
    
    var stringFormatter  : ( (String) -> NSAttributedString )?
    
    var alternateShading : ( () -> NSColor? )?
    
    var mainFrame : NSRect!
    
    var associatedView : ConnectionAttributesView!
    
    var headerStringAttributes : StringAttributes = ( font: NSFont(name: "Avenir-Heavy", size: 13), size: 13, color: NSColor.white )
    
    var memberStringAttributes : StringAttributes = ( font: NSFont(name: "Futura",       size: 11), size: 11, color: NSColor.white )
    
    
    // MARK: - init() & finalizeBox()
    
    init(viewRef: ConnectionAttributesView, width: CGFloat = 200, height: CGFloat = 25, ratio: CGFloat = 0.618) {
        
        super.init()
        
        let fr  = NSMakeRect( 0, 0, width, height)
        
        mainFrame = fr 
        
        defStringFormat( memberStringAttributes )
        
        defAlternatingShader(baseTone: 0.23, variance: 0.035)
        
        self.associatedView = viewRef
        
        self.width  = width
        
        self.height = height
        
        self.ratio  = ratio
        
        wrapper = NSBox(frame: fr)
        
        wrapper.contentView = NSView(frame: fr)
    }
    
    
    
    func finalizeBox(_ ratio: CGFloat = 0.618) {
        
        guard let panelView = wrapper.contentView else { return }
        
        wrapper.boxType      = .custom
        
        wrapper.borderType   = .lineBorder
        
        wrapper.borderWidth  = 0
        
        wrapper.cornerRadius = 0
        
        wrapper.borderColor  = NSColor.gray
        
        for row in rowViews { panelView.addSubview( row ) }
        
        let subs = panelView.subviews
        
        for (index, sv) in subs.enumerated() {
            
            if index == 0 { sv.anchorToEdge(.Top, padding: 0, width: width, height: height) }
                
            else { sv.align(.UnderCentered, relativeTo: subs[index-1], padding: 0, width: width, height: height)  }
        }
        
        wrapper.sizeToFit()
        
        panelView.needsDisplay = true
    }
    
    

    
    //  MARK: - private factory method
    
    fileprivate func addControlView(_ ctrlView:ControlView, withLabel aLabel:String) {
        
        let label = NSTextField(frame: mainFrame)
        
        label.attributedStringValue = formatString( aLabel )
        
        label.alignment = .natural
        
        label.isBordered = false
        
        label.isEditable = false
        
        ctrlView.attachControl { ( cview : NSControl ) in
            
            cview.target = self
            
            cview.action = #selector(AttributesPanelArchitect.cellValueChanged(_:))
        }
        
        let mText = ctrlView.isText()
        
        let mToggle = ctrlView.isToggle()
        
        if let tf = mText   { tf.isBordered = false }
        
        if let tg = mToggle { tg.isBordered = false }
        
        
        let fr = mainFrame
        
        let rowView = NSView(frame: fr!)
        
        let labelView = label
        
        
        let color = genAlternateColor()
        
        labelView.backgroundColor = color
        
        let cntrlView = ctrlView.prepareView(color)
        
        let newRatio = ctrlView.determineSizeOfControl( ratio )
        
        rowView.addSubview( labelView )
        
        rowView.addSubview( cntrlView )
        
        labelView.frame = NSMakeRect((fr?.origin.x)!, (fr?.origin.y)!, (fr?.size.width)! * ( 1 - newRatio ), (fr?.size.height)!)
        
        cntrlView.frame = NSMakeRect((fr?.origin.x)! + ((fr?.size.width)! * ( 1 - newRatio )), (fr?.origin.y)!, (fr?.size.width)! * newRatio, (fr?.size.height)!)
        
        rowViews.append( rowView )
    }
    
    
    // MARK: - addAttribute methods
    
    
    func addHeader(_ text: String) {
        
        let header = NSTextField(frame: mainFrame)
        
        header.attributedStringValue = formatString( text )
        
        header.alignment = .natural
        
        header.isBordered = true
        
        let color = genAlternateColor()
        
        header.backgroundColor = color
        
        rowViews.append( header )
    }
    
    // notifications  NSControlTextDidEndEditingNotification
    
    func addTextFieldWithLabel(_ aLabel: String, datastore: Property<String?>) {
        
        let txtfld = NSTextField(frame: mainFrame) {
            
            $0.attributedStringValue = self.formatString( "" )
            
            $0.isEditable  = true
            
            $0.isBezeled   = true
            
            $0.alignment = .natural
            
            $0.delegate  = self.associatedView
        }
        
        
        
        //txtfld.rAttributedText
        
        txtfld.rText.bindTo( datastore )
        
        datastore.bindTo( txtfld.rText )
        
        addControlView( ControlView.text( txtfld ), withLabel: aLabel )
        
        txtfld.rText
            .observeNext { val in
                
                guard let txt = val else { return }
            
                printLog("AttributesPanelArchitect: The VIEW has detected a value change in its text field, of \(txt)")
                
            }.disposeIn(rBag)
}

    
    
    func addBoolFieldWithLabel(_ aLabel: String) {
        
        let togl = NSButton(frame: mainFrame)
        
        togl.setButtonType(NSButtonType.SwitchButton)
        
        if let tc = togl.cell as? NSButtonCell {
            
            tc
        }
        
        //togl.alignment = .Center
        
        togl.title = ""
        
        togl.alternateTitle = ""
        
        addControlView( ControlView.toggle( togl ), withLabel: aLabel )
    }
    
    
    func addNumberFieldWithLabel(_ aLabel: String, datastore: Property<String?>) {
        
        let txtfld = NSTextField(frame: mainFrame) {

            $0.formatter = NumberFormatter()
            
            $0.isEditable  = true
            
            $0.isBezeled   = true
            
            $0.delegate  = self.associatedView
        }
        
        if let v = datastore.value {
            
            txtfld.attributedStringValue = self.formatString(v)
            
            txtfld.needsDisplay = true
        }
        
        else { txtfld.attributedStringValue = self.formatString("") }
        
        txtfld.rText.bindTo( datastore )
        
        datastore.bindTo( txtfld.rText )
        
        addControlView( ControlView.text( txtfld ), withLabel: aLabel )
        
        txtfld.rText
            .observeNext { val in
                
                guard let txt = val else { return }
            
                printLog("AttributesPanelArchitect: The VIEW has detected a value change in its num field, of \(txt)")
        
            }.disposeIn(rBag) 
    }
    
     
     
    func addReactivePassiveTextFieldWithLabel(_ aLabel: String, text: Property<String?>) {
        
        let txtfld = NSTextField(frame: mainFrame)
        
        txtfld.isEditable = false
        
        txtfld.isBezeled = true
        
        addControlView( ControlView.text( txtfld ), withLabel: aLabel )
        
        text.bindTo( txtfld.rText )
        
        guard let txt = text.value else { return }
        
        txtfld.attributedStringValue = formatString( txt )
    }
    
    
    // MARK: - triggered action
    
    
    // connect a ReactiveKit observer to NSNotification dispatch, to detect 'cellValueChanged' notifications originating from here.
    
    func cellValueChanged(_ sender: AnyObject) {
        
        //let cell : NSCell? = matrix.selectedCell()
        
        //guard let c = cell, objval = c.objectValue else { return }
        
        //results.replaceObjectAtIndex(matrix.selectedRow, withObject: objval)
    }
    
    
    //  MARK: - formatter configuration  StringAttributes
    
    func defStringFormat(_ font: NSFont?, size: CGFloat, color: NSColor) {
        
        let theFont = NSFont.getBackupOrPreferredFont(font, size: size)
        
        stringFormatter = { str in NSAttributedString( string: str, attributes:[NSFontAttributeName: theFont, NSForegroundColorAttributeName: color ]) }
    }
    
    func defStringFormat(_ tuple: StringAttributes) {
        
        let theFont = NSFont.getBackupOrPreferredFont(tuple.font, size: tuple.size)
        
        stringFormatter = { str in NSAttributedString( string: str, attributes:[NSFontAttributeName: theFont, NSForegroundColorAttributeName: tuple.color ]) }
    }
    
    
    func defAlternatingShader(baseTone: CGFloat, variance: CGFloat) {
        
        let shader = AlternatingShader(baseTone: baseTone, variance: variance)
        
        alternateShading = { () in shader.next() }
    }
    
    func setTextStyleToHeader() {
        
        defStringFormat( headerStringAttributes )
    }
    
    func setTextStyleToMember() {
        
        defStringFormat( memberStringAttributes )
    }
    
    
    
    //  MARK: - private
    
    fileprivate func formatString(_ str: String) -> NSAttributedString {
        
        var result : NSAttributedString
        
        if let formatter = stringFormatter {
            
            result = formatter( str )
        }
            
        else {
            
            result =  NSAttributedString( string: str, attributes:[NSFontAttributeName: NSFont.messageFont(ofSize: 12), NSForegroundColorAttributeName: NSColor.black ] )
        }
        
        return result
    }
    
    
    fileprivate func genAlternateColor() -> NSColor {
        
        var color = NSColor.darkGray
        
        if let shader = alternateShading { color = shader()! }
        
        return color
    }
    
}





