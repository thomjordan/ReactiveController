//
//  CocoaClassExtensions.swift
//  ReactiveControls
//
//  Created by Thom Jordan on 12/5/15.
//  Copyright © 2015 Thom Jordan. All rights reserved.
//

import Cocoa

// string to float (returns 0.0 if string is not a number)
extension Float { init?(_ value: String) { self = (value as NSString).floatValue } }

extension Float64 { init?(_ value: String) { self = Float64((value as NSString).doubleValue) } }

extension CGFloat { init?(_ value: String) { self = CGFloat((value as NSString).floatValue) } }


class FlippedView: NSView {
    
    override var isFlipped:Bool {
        
        get { return true }
    }
}

// ---------------------------------------------
//  MARK:  NSPoint
// ---------------------------------------------

extension NSPoint : Codable {
    
    public enum CodingKeys : String, CodingKey {
        case xval
        case yval
    }
    
    public init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try vals.decode( CGFloat.self, forKey: .xval )
        self.y = try vals.decode( CGFloat.self, forKey: .yval )
    }
    
    public func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( x, forKey: .xval )
        try bin.encode( y, forKey: .yval )
    }
}



// ---------------------------------------------
//  MARK:  NSRect
// ---------------------------------------------

extension NSRect : Codable {
    
    public enum CodingKeys : String, CodingKey {
        case xval
        case yval
        case wdth
        case hght
    }
    
    public init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        let x = try vals.decode( CGFloat.self, forKey: .xval )
        let y = try vals.decode( CGFloat.self, forKey: .yval )
        let w = try vals.decode( CGFloat.self, forKey: .wdth )
        let h = try vals.decode( CGFloat.self, forKey: .hght )
        self.origin = NSMakePoint( x, y )
        self.size   = NSMakeSize( w, h )
    }
    
    public func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( origin.x, forKey: .xval )
        try bin.encode( origin.y, forKey: .yval )
        try bin.encode( width,    forKey: .wdth )
        try bin.encode( height,   forKey: .hght )
    }
}


// ---------------------------------------------
//  MARK:  NSCoder
// ---------------------------------------------

extension NSCoder {
    
    func encode(_ key: String, value: AnyObject?) {
        
        self.encode(value, forKey: key)
        
    }
    
    func decode<T>(_ key: String) -> T? {
        
        return self.decodeObject(forKey: key) as? T
    }
}


/*
extension NSCoding {
    func encode() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    static func decode(data: NSData) -> Self? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Self
    }
}
*/



// --------------------------------------------------------------------
//  MARK:  NSTextField 
//  
//   For defining attributes via closure appending to init() call.
//    This same pattern can be used for various UI-based classes in
//    Cocoa, e.g. NSButton, NSControl, etc.
//
//   Determine which higher-level
//    classes should be appropriately extended, to cover all or most of
//    the Cocoa UI-like subclasses, e.g. any object that might require
//    the setting of several attributes at once.
//
// --------------------------------------------------------------------


extension NSTextField {
    
    convenience init(frame: NSRect, _ build: (NSTextField) -> Void) {
        
        self.init(frame: frame)
        
        build(self)
    }
}



// ---------------------------------------------
//  MARK:  NSViewController
// ---------------------------------------------


extension NSViewController {
    
    func enterResponderChain() {  // only call after self.view has been instantiated and holds a NSView object
        
        nextResponder = view
        
        for sv in view.subviews {
            
            sv.nextResponder = self
            
        }
    }
}


// ---------------------------------------------
//  MARK:  NSView
// ---------------------------------------------

//public let AutoHeight : CGFloat = 0 // -1

extension NSView {
    
    // from: https://developer.apple.com/library/mac/qa/qa1346/_index.html
    
    @nonobjc static var unitSize : NSSize = NSMakeSize(1.0,1.0)
    
    // Returns the scale of the receiver's coordinate system, relative to the window's base coordinate system.
    var scale : NSSize {
        return convert( NSView.unitSize, from: nil )
    }
    
    // Sets the scale in absolute terms.
    func setScale(_ newScale: CGFloat) {
        printLine("NSView: setScale() called with scale value \(newScale)")
        resetScaling()                   // First match our scaling to the window's coordinate system.
        scaleUnitSquare(to: NSMakeSize(newScale,newScale))  // Then, set the scale.
        updateSelf()            // Finally, mark the view as needing to be redrawn.
        
        for s in subviews { s.setScale(newScale) }  // recursive call
    }
    
    // Makes the scaling of the receiver equal to the window's base coordinate system.
    func resetScaling() {
        scaleUnitSquare( to: convert( NSView.unitSize, from: nil ) )
    }
    
    func updateSelf() {
        DispatchQueue.main.async { [weak self] in
            self?.needsDisplay = true
        }
    }
    
    // -----
    /*
    public var superFrame: CGRect {
        guard let superview = superview else { return CGRect.zero }
        return superview.frame
    }

    //public func setHeightAutomatically() { self.si }
    
    public func anchorInCenter(width: CGFloat, height: CGFloat) {
        let xOrigin : CGFloat = (superFrame.width / 2.0) - (width / 2.0)
        let yOrigin : CGFloat = (superFrame.height / 2.0) - (height / 2.0)
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }*/
    
    func getCenteredFrameAboveCompanionViewInSuperview(_ companionView: NSView) -> (newFrame: NSRect, xOffset: CGFloat) {
        
        let mFrame = self.frame
        let cFrame = companionView.frame
        
        let xOffset   = cFrame.size.width/2 - mFrame.size.width/2
        let mLeadingX = cFrame.origin.x + xOffset
        let mBottomY  = cFrame.origin.y + cFrame.size.height + 1
        
        let newFrame = NSMakeRect(mLeadingX, mBottomY, mFrame.size.width, mFrame.size.height)
        
        return (newFrame: newFrame, xOffset: xOffset) 
    }
    
    func getCenteredFrameAboveCompanionView(_ companionView: NSView) -> (topFrame: NSRect, totalFrame: NSRect) {
        
        let mFrame = self.frame
        let cFrame = companionView.frame
        
        let xOffset   = companionView.xMid - mFrame.size.width/2
        let mLeadingX = cFrame.origin.x + xOffset
        let mBottomY  = companionView.yMax + 1
        
        var topFrame   : NSRect
        var totalFrame : NSRect
        
        if xOffset >= 0 {
            
            topFrame   = NSMakeRect(mLeadingX, mBottomY, mFrame.size.width, mFrame.size.height)
            totalFrame = NSMakeRect(cFrame.origin.x, cFrame.origin.y, cFrame.size.width, cFrame.size.height+mFrame.size.height)
        }
        
        else {
            
            topFrame   = NSMakeRect(mLeadingX, mBottomY, mFrame.size.width, mFrame.size.height)
            totalFrame = NSMakeRect(cFrame.origin.x+xOffset, cFrame.origin.y, cFrame.size.width+(xOffset*(-2)), cFrame.size.height+mFrame.size.height)
        }
        
        return (topFrame: topFrame, totalFrame: totalFrame)
    }
    
   
    func defBackgroundColor(_ color: NSColor) { // ( has a "capital-B" in method name )
        
        layer = CALayer()
        
        wantsLayer = true
        
        layer!.backgroundColor = color.cgColor
        
    }
    

    
    func defbackgroundColor(_ color: NSColor) {
        
        let bklayer = CALayer()
        
        bklayer.backgroundColor = color.cgColor
        
        self.wantsLayer = true
        
        self.layer = bklayer
        
    }
    
    func defShadow(_ radius:CGFloat = 5, offset: NSSize = NSMakeSize(4,-4), opacity: Float = 0.75, color: NSColor = NSColor.black) {
    
        let layer = CALayer()
    
        self.wantsLayer = true
        
        layer.masksToBounds = false
    
        layer.shadowColor = color.cgColor
        
        layer.shadowOpacity = opacity
        
        layer.shadowOffset = offset
        
        layer.shadowRadius = radius
        
        self.layer = layer
    
    }
    
}


extension NSViewController {
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.view.needsDisplay = true
        }
    }
}


extension NSView {
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.needsDisplay = true
        }
    }
    
    func adjustFrame(_ scalar: CGFloat = 1.0) {
        let w = frame.width
        let h = frame.height
        frame.size = CGSize(width: w*scalar, height: h*scalar)
        bounds.size = frame.size
    }
    
    func createBackgroundLayer(_ color: CGColor) {
        self.layer = CALayer()
        self.wantsLayer = true
        self.layer!.backgroundColor = color
    }
    
    func localizePoint(_ sender: NSEvent) -> NSPoint {
        let eventLocation = sender.locationInWindow
        return self.convert(eventLocation, from: nil)
    }
    
    func mouseLocationInWindow() -> NSPoint {  // returns current mouseLocation converted from screen coordinates to receiver's window coordinates
        guard let theWindow = self.window else { return NSMakePoint(0,0) }
        let mloc  = NSEvent.mouseLocation
        return theWindow.convertFromScreen(NSMakeRect(mloc.x, mloc.y, 0, 0)).origin
    }
    
    
    func pushSubview(_ aView: NSView) {
        
        var rev : [NSView] = self.subviews.reversed()
        
        rev.append( aView )
        
        self.subviews = rev.reversed()
    }
}


extension NSView {
    
    func CGContextAddReverseRect(_ ctx: CGContext, frame: CGRect) {
        
        ctx.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y))
        ctx.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        ctx.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y+frame.size.height))
        ctx.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
        ctx.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y))
    }
    
    
    func newPathForRoundedRect(_ rect: CGRect, radius:CGFloat) -> CGPath {
        
        let retPath : CGMutablePath = CGMutablePath()
        let innerRect = rect.insetBy(dx: radius, dy: radius)
        let inside_right = innerRect.origin.x + innerRect.size.width
        let outside_right = rect.origin.x + rect.size.width
        let inside_bottom = innerRect.origin.y + innerRect.size.height
        let outside_bottom = rect.origin.y + rect.size.height
        let inside_top = innerRect.origin.y
        let outside_top = rect.origin.y
        let outside_left = rect.origin.x
        
        
        retPath.move(to: CGPoint(x: innerRect.origin.x, y: outside_top))
            
        retPath.addLine(to: CGPoint(x: inside_right, y: outside_top))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_right, y: outside_top), tangent2End: CGPoint(x: outside_right, y: inside_top), radius: radius)
        
        retPath.addLine(to: CGPoint(x: outside_right, y: inside_bottom))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_right, y: outside_bottom), tangent2End: CGPoint(x: inside_right, y: outside_bottom), radius: radius)
        
        retPath.addLine(to: CGPoint(x: innerRect.origin.x, y: outside_bottom))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_left, y: outside_bottom), tangent2End: CGPoint(x: outside_left, y: inside_bottom), radius: radius)
        
        retPath.addLine(to: CGPoint(x: outside_left, y: inside_top))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_left, y: outside_top), tangent2End: CGPoint(x: innerRect.origin.x, y: outside_top), radius: radius)
        
        retPath.closeSubpath()
        
        
        return retPath
        
        // CGPathMoveToPoint(retPath, nil, innerRect.origin.x, outside_top)
        // CGPathAddLineToPoint(retPath, nil, inside_right, outside_top)
        // CGPathAddArcToPoint(retPath, nil, outside_right, outside_top, outside_right, inside_top, radius)
        // CGPathAddLineToPoint(retPath, nil, outside_right, inside_bottom)
        // CGPathAddArcToPoint(retPath, nil,  outside_right, outside_bottom, inside_right, outside_bottom, radius)
        // CGPathAddLineToPoint(retPath, nil, innerRect.origin.x, outside_bottom)
        // CGPathAddArcToPoint(retPath, nil,  outside_left, outside_bottom, outside_left, inside_bottom, radius)
        // CGPathAddLineToPoint(retPath, nil, outside_left, inside_top)
        // CGPathAddArcToPoint(retPath, nil,  outside_left, outside_top, innerRect.origin.x, outside_top, radius)
        
        /*
        retPath.addArc(tangent1End: CGPoint(x: outside_right, y: outside_top), tangent2End: CGPoint(x: outside_right, y: inside_top), radius: radius)
        
        retPath.addLine(to: CGPoint(x: outside_right, y: inside_bottom))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_right, y: outside_bottom), tangent2End: CGPoint(x: inside_right, y: outside_bottom), radius: radius)
        
        retPath.addLine(to: CGPoint(x: innerRect.origin.x, y: outside_bottom))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_left, y: outside_bottom), tangent2End: CGPoint(x: outside_left, y: inside_bottom), radius: radius)
        
        retPath.addLine(to: CGPoint(x: outside_left, y: inside_top))
        
        retPath.addArc(tangent1End: CGPoint(x: outside_left, y: outside_top), tangent2End: CGPoint(x: innerRect.origin.x, y: outside_top), radius: radius)
        
        retPath.closeSubpath()
 
         */
    }
}


protocol HasModifiers { }

extension HasModifiers {
    
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags], excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags, excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags], excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        result = result && !flags.contains(excludes)
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags, excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        result = result && !flags.contains(excludes)
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    
    /*
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        return result
    }
    func modifiers(_ sender:NSEvent?, excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && !flags.contains(excludes)
        return result
    }
    */ 
}



// ---------------------------------------------
//  MARK:  NSResponder
// ---------------------------------------------

extension NSResponder {
    
    func printResponderChain(_ responder: NSResponder?) {
        guard let rsp = responder else { return }
        printLine(rsp)
        printResponderChain(rsp.nextResponder)
    }
    
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags], excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags, excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags], excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        result = result && !flags.contains(excludes)
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags, excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        result = result && !flags.contains(excludes)
        return result
    }
    func modifiers(_ sender:NSEvent?, includes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in includes { result = result && flags.contains(key) }
        return result
    }
    func modifiers(_ sender:NSEvent?, excludes:[NSEvent.ModifierFlags]) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        for key in excludes { result = result && !flags.contains(key) }
        return result
    }
    
    /*
    func modifiers(_ sender:NSEvent?, includes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && flags.contains(includes)
        return result
    }
    func modifiers(_ sender:NSEvent?, excludes:NSEvent.ModifierFlags) -> Bool {
        guard let flags = sender?.modifierFlags else { return false }
        var result = true
        result = result && !flags.contains(excludes)
        return result
    }
 */ 
    
}


// ---------------------------------------------
//  MARK:  NSImage
// ---------------------------------------------


extension NSImage {
    
    class func swatchWithColor(_ color: NSColor, size: NSSize) -> NSImage {
        
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        
        image.unlockFocus()
        
        return image
        
    }
    
}


extension NSFont {
    
    class func getBackupOrPreferredFont(_ preferredFont: NSFont?, size: CGFloat = 12) -> NSFont {
        
        var font : NSFont = NSFont.messageFont(ofSize: size)
        
        if let _ = preferredFont { font = preferredFont! }
        
        return font
    }
}



extension Array {
    
    static func initWithSize(_ n: Int) -> [Array.Element?] {
        var result : [Array.Element?] = []
        for _ in 0..<n { result.append( nil ) }
        return result
    }
    
    func rotated(_ amt: Int = 1) -> [Element] {
        var amount : Int = amt
        while amount < 0 { amount += count }
        let offset = amount % count
        return Array(self[offset ..< count] + self[0 ..< offset])
    }
    
    mutating func rotate(_ amt: Int = 1) {
        self = rotated(amt)
    }
    
    // let nums = Array(0..<64).rotated(8)
}


extension Array where Element == Int {
    var asString : String {
        var result : String = ""
        for num in self { result.append( "\(String(num)), " ) }
        if result.count > 2 { result.removeLast() ; result.removeLast() }
        return result
    }
}

extension Int {
    var asString : String { return String(self) }
}

extension Float64 {
    var asString : String { return String(self) }
}



extension NSColor {
    
    class func makeRandom() -> NSColor {
        
        srand48( Int(CFAbsoluteTimeGetCurrent()) )
        
        let randomRed:CGFloat = CGFloat(drand48())
        
     //   srand48( Int(CFAbsoluteTimeGetCurrent()) )
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
     //   srand48( Int(CFAbsoluteTimeGetCurrent()) )
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return NSColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

// ---------------------------------------------
//  MARK:  NSOpenPanel
// ---------------------------------------------

extension NSOpenPanel {
    
    var selectUrl: URL? {
        
        title = "Select File"
        
        allowsMultipleSelection = false
        
        canChooseDirectories = false
        
        canChooseFiles = true
        
        canCreateDirectories = false
        
        //allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
        
        return runModal().rawValue == NSFileHandlingPanelOKButton ? urls.first : nil
    }
}









