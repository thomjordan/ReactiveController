//
//  ConnectionAttributes.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/28/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import Neon
import ReactiveKit



let stringPad : String = "   "




class LabeledAttributeParameter : NSObject, NSCoding {
    
    var label : String!
    
    var param : AttributeParameter!
    
    
    init( label: String, param: AttributeParameter ) {
        
        super.init()
        
        self.label = label
        
        self.param = param
        
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        //label = aDecoder.decode("label")
        
        label = aDecoder.decodeObject(forKey: "label") as! String
        
        param = rewrapDecodedAttribute( aDecoder )
    }
    
    
    @objc func encode(with aCoder: NSCoder) {
        
        //aCoder.encode("label", value: self.label)
        
        aCoder.encode(self.label, forKey: "label")
        
        encodeDisambiguatedAttribute(aCoder, attr: self.param)
    }
    
    
    
    func encodeDisambiguatedAttribute(_ aCoder: NSCoder, attr: AttributeParameter) {
        
        if let anInt   = attr.intBind() {
            
            aCoder.encode("Int", forKey: "AttributeType")
            
            aCoder.encode(anInt.value!, forKey: "Int")   ; return
        }
        
        if let aBool   = attr.boolBind() {
            
            aCoder.encode("Bool", forKey: "AttributeType")
            
            aCoder.encode(aBool.value!, forKey: "Bool")  ; return
        }
        
        if let aString = attr.stringBind() {
            
            aCoder.encode("String", forKey: "AttributeType")
            
            aCoder.encode(aString.value!, forKey: "String")  ; return
        }
    }
    
    
    /*
    func encodeDisambiguatedAttribute2(aCoder: NSCoder, attr: AttributeParameter?) {
        
        if let anInt   = attr?.intBind() {
            
            aCoder.encode("AttributeType", value: "Int")
            
            aCoder.encode("Int", value: anInt.value) ; return
        }
        
        if let aBool   = attr?.boolBind() {
            
            aCoder.encode("AttributeType", value: "Bool")
            
            aCoder.encode("Bool", value: aBool.value) ; return
        }
        
        if let aString = attr?.stringBind() {
            
            aCoder.encode("AttributeType", value: "String")
            
            aCoder.encode("String", value: aString.value) ; return
        }
    }
    */
    
    
    
    
    func rewrapDecodedAttribute(_ aDecoder: NSCoder) -> AttributeParameter? {
        
        let attrType : String = aDecoder.decodeObject(forKey: "AttributeType") as! String
            
        switch attrType {
            
        case "Int" :
            
            let anInt : String = aDecoder.decodeObject(forKey: "Int") as! String
                
            return AttributeParameter.newIntBind( anInt )
            
        case "Bool" :
            
            let aBool : Bool = aDecoder.decodeObject(forKey: "Bool") as! Bool
                
            return AttributeParameter.newBoolBind( aBool )
            
            
        case "String" :
            
            let aString : String = aDecoder.decodeObject(forKey: "String") as! String
                
            return AttributeParameter.newStringBind( aString )
        
            
        default :
            
            return nil
        }
    }
    
    
    /*
    func rewrapDecodedAttribute2(aDecoder: NSCoder) -> AttributeParameter? {
        
        if let attrType : String = aDecoder.decode("AttributeType") {
            
            switch attrType {
                
            case "Int" :
                
                if let anInt : String = aDecoder.decode("Int") {
                    
                    return AttributeParameter.newIntBind( anInt )
                }
                
            case "Bool" :
                
                if let aBool : Bool = aDecoder.decode("Bool") {
                    
                    return AttributeParameter.newBoolBind( aBool )
                }
                
            case "String" :
                
                if let aString : String = aDecoder.decode("String") {
                    
                    return AttributeParameter.newIntBind( aString )
                }
                
            default :
                
                return nil
            }
        }
        
        return nil
    }
    */
    
    
}




protocol ConnectionAttributesViewModelType {
    
    var header : String { get }
    
    var sourceUnitName : Property<String?> { get }
    
    var sourceDataName : Property<String?> { get }
    
    var targetUnitName : Property<String?> { get }
    
    var routeInfoAttributes : [(String, Property<String?>)] { get set }
    
    var signalTaskAttributes : [LabeledAttributeParameter] { get set }
    
    mutating func collectAttributes() -> ([(String, Property<String?>)], [LabeledAttributeParameter])
}




class ConnectionAttributesViewModel : ConnectionAttributesViewModelType {
    
    var header : String = "Connection"
    
    var sourceUnitName : Property<String?> = Property("")
    
    var sourceDataName : Property<String?> = Property("")
    
    var targetUnitName : Property<String?> = Property("")
    
    var routeInfoAttributes : [(String, Property<String?>)] = []
    
    var signalTaskAttributes : [LabeledAttributeParameter] = []
    
    
    
    init(taskArgs: [LabeledAttributeParameter]) {
        
        header = "Connection"
        
        routeInfoAttributes = [("Source", sourceUnitName), ("Message", sourceDataName), ("Target", targetUnitName)]
        
        signalTaskAttributes = taskArgs 
    }
    
    func collectAttributes() -> ([(String, Property<String?>)], [LabeledAttributeParameter]) {
        
        routeInfoAttributes = [("Source", sourceUnitName), ("Message", sourceDataName), ("Target", targetUnitName)]
        
        let theTaskAttrs = signalTaskAttributes
        
        return (routeInfoAttributes, theTaskAttrs)
    }
}



class ConnectionAttributesView : NSBox, NSTextFieldDelegate {
    
    weak var hostConnection : WorkspaceConnection!
    
   // weak var model : ConnectionAttributesViewModel!
    
    var model : ConnectionAttributesViewModelType!
    
    var panel : AttributesPanelArchitect!
    
    
    var width  : CGFloat = 200.0
    
    var height : CGFloat = 25.0
    
    let pad    : CGFloat = 0
    
    
    var headerAndAttributeViews : [NSView] = []
    
    var canEditConstraintField  : Bool = false // replace this with something that can determine or pass along the pin-type
    
    
    init(hostConnection: WorkspaceConnection) {
        
        super.init(frame: NSMakeRect(0,0,200,200))
        
        self.panel = AttributesPanelArchitect(viewRef: self)
        
        self.hostConnection = hostConnection
        
        self.model = hostConnection.attrModel
        
        panel.setTextStyleToHeader()
        
        panel.addHeader( model.header )
        
        panel.setTextStyleToMember() 
        
        let (routeAttrs, taskAttrs) = model.collectAttributes() // ***
        
        for attr in routeAttrs { panel.addReactivePassiveTextFieldWithLabel(attr.0, text: attr.1) }
        
        addParsedTaskParametersToPanel(taskAttrs)
        
        panel.finalizeBox()
        
        boxType      = .custom
        
        borderType   = .lineBorder
        
        borderWidth  = 2
        
        cornerRadius = 2
        
        borderColor  = NSColor.gray
        
        let layer = CALayer()
        
        self.wantsLayer = true
        
        layer.masksToBounds = true
        
        contentViewMargins = NSMakeSize(1, 1)
        
        self.contentView = panel.wrapper
        
        sizeToFit()
        
        needsDisplay = true
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
//    override func controlTextDidEndEditing(obj: NSNotification) { printLog("In \(obj.object) text was editing and changed to \(obj.object?.stringValue)") }
    
    
    
    fileprivate func addParsedTaskParametersToPanel(_ attrs: [LabeledAttributeParameter]) {
        
        for attr in attrs {
            
            if let pin = attr.param.intBind() {
                
                panel.addNumberFieldWithLabel(attr.label, datastore: pin)
                
                if pin.value != nil {
                    
                }
            }
    
            else if let pin = attr.param.stringBind() {
                
                panel.addTextFieldWithLabel(attr.label, datastore: pin)
            }
            
            // else if let pin = attr.1.boolBind() { panel.addBoolFieldWithLabel(attr.0) //, datastore: pin) }
        }
    }
}


















