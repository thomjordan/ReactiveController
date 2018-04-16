//
//  WorkpageTabsView.swift
//  WorkpageTabsView
//
//  Created by Thom Jordan on 5/19/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import AppKit


class CustomSegmentedCell : NSSegmentedCell {
    
    override func drawSegment(_ segment: Int, inFrame frame: NSRect, with controlView: NSView) {
        
        if segment == selectedSegment {
            mainBGColor.setFill()
            //NSRectFill(frame)
            NSDrawButton(frame, frame) 
        }
        
        super.drawSegment(segment, inFrame: frame, with: controlView)
    }
}



class WorkpageTabsView : NSTabView {
    
    weak var tabsController : WorkpageTabsViewController?
    
    var backgroundColor       : NSColor! { didSet { updateView() } }
    var windowBackgroundColor : NSColor! { didSet { updateView() } }
    var bezelColor            : NSColor! { didSet { updateView() } }
    
    var segmentedControl : NSSegmentedControl!
    var addButton        : NSButton!
    
    var tabnum     : Int     = 0
    var maxWidth   : CGFloat = 0
    let kSegHeight : CGFloat = 32
    let kRadius    : CGFloat = 2
    let bSize      : CGFloat = 26
    
    
    func rework() {
        
        let items = tabViewItems
        let n = items.count
        
        let h = kSegHeight, w = min(CGFloat(60 + 70 * n), self.frame.size.width-kSegHeight)
        var fr = NSRect()
        fr.size.width = w
        fr.size.height = h
        fr.origin.x = self.bounds.origin.x + bSize
        fr.origin.y = self.bounds.origin.y
        
        var pbFrame = NSRect()
        pbFrame.size.width  = bSize
        pbFrame.size.height = bSize
        pbFrame.origin.x = self.bounds.origin.x
        pbFrame.origin.y = self.bounds.origin.y
        
        if addButton        != nil {        addButton.removeFromSuperview() }
        if segmentedControl != nil { segmentedControl.removeFromSuperview() }
        
        addButton = NSButton(frame:pbFrame)
        addButton.setButtonType( NSButton.ButtonType.momentaryPushIn )
        addButton.isBordered = true
        addButton.bezelStyle = NSButton.BezelStyle.texturedSquare
        addButton.image = NSImage(named: NSImage.Name.addTemplate)
        
        addButton.target = tabsController
        addButton.action = #selector(tabsController?.addTab(_:))
        addButton.isSpringLoaded = true
        addButton.cell!.backgroundStyle = NSView.BackgroundStyle.dark
//        addButton.shadow = NSShadow()
        addButton.frame = pbFrame
        
        segmentedControl = NSSegmentedControl(frame: fr)
        segmentedControl.cell = CustomSegmentedCell()
        segmentedControl.cell?.controlTint = NSControlTint.clearControlTint
        segmentedControl.segmentStyle = NSSegmentedControl.Style.texturedSquare
        segmentedControl.segmentCount = n
        segmentedControl.autoresizesSubviews = true
        
        addSubview(segmentedControl)
        addSubview(addButton)
        
        
        for i in 0..<n {
            
            let closeMenu = NSMenu()
            
            closeMenu.addItem(withTitle: "close", action: #selector(tabsController?.removeTab(_:)), keyEquivalent: "")
            closeMenu.item(at: 0)?.isEnabled = true
            closeMenu.item(at: 0)?.target    = tabsController
            
            
            let item = items[i]
            segmentedControl.setLabel(item.label, forSegment: i)
            segmentedControl.setWidth(0, forSegment: i)
            segmentedControl.target = tabsController
            segmentedControl.action = #selector(tabsController?.ctrlSelected(_:))
            
            segmentedControl.setMenu(closeMenu, forSegment: i)

        }
        
        // Record the 'ideal' max size (and ideally update it when we see
        // more addSubviews coming through).
        
        let s = segmentedControl.cell?.cellSize
        
        maxWidth = s!.width
        
        if backgroundColor == nil {
            
            backgroundColor = NSColor(deviceRed: 228.0/255, green: 228.0/255, blue: 228.0/255, alpha: 1.0)
        }
        
        if windowBackgroundColor == nil {
            
            windowBackgroundColor = NSColor(deviceRed: 237.0/255, green: 237.0/255, blue: 237.0/255, alpha: 1.0)
        }
        
        if bezelColor == nil {
            
            bezelColor = NSColor.darkGray
        }
        
        updateSegmentToMatchTabViewSelection()
    }
    
    
    override init(frame frameRect: NSRect) {
        
        // printLog("WorkpageTabsView: override init() called.")
        
        super.init(frame: frameRect)
        
        isHidden = true
        
        tabnum = 1
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func awakeFromNib() {
        
        rework()
        
        self.tabViewType = .noTabsNoBorder
        
        backgroundColor = mainBGColor
    }
    
    
    // drawing and alignments
    
    override func viewWillDraw() {
        
        // Recenter the segment box at the top if needed. We prolly should
        // detect when we get resized - and only do this then. How ?
        
        var frame = NSRect()
        
        frame.size.width = min(maxWidth,self.frame.size.width-kSegHeight);
        frame.size.height =  (segmentedControl.cell)!.cellSize.height;
        //    frame.origin.x = self.bounds.origin.x  + (self.bounds.size.width - frame.size.width) / 2;
        frame.origin.x = self.bounds.origin.x + bSize;
        frame.origin.y = self.bounds.origin.y;
        
        segmentedControl.frame = frame
        
        var pbFrame = NSRect()
        
        pbFrame.size.width  = bSize;
        pbFrame.size.height = bSize;
        pbFrame.origin.x = self.bounds.origin.x;    //+ self.bounds.size.width;
        pbFrame.origin.y = self.bounds.origin.y;
        
        addButton.frame = pbFrame
        addButton.isSpringLoaded = true
        addButton.cell?.backgroundStyle = NSView.BackgroundStyle.dark
    }
    
    
    
    
    func addTVItem() {  // gets called from observer (inserts) on WorkpagesControllersStore:pageCollection (a MutableObservableArray)
        
        tabnum += 1
        
        let str    = "   Page \(tabnum)   "
        
        let item   = NSTabViewItem(identifier: str)
        
        item.label = str
        
        super.addTabViewItem(item)
        
        awakeFromNib()
        
        updateView()
        
        // printLog("WorkpageTabsView: addTVItem() called.")
    }
    
    
    func removeTVItem(at index: Int) {  // gets called from observer (deletes) on WorkpagesControllersStore:pageCollection (a MutableObservableArray)
        
        selectTabViewItem(at: index)  // super.selectTabViewItem(at: index)
        
        let item_ = super.selectedTabViewItem
        
        guard let item = item_ else { return }
        
        super.removeTabViewItem(item)
        
        awakeFromNib()
        
        updateView()
        
        tabnum -= 1
        
        // printLog( String(format:"WorkpageTabsView: removeTVItem(at: %d) called.", index))
    }
    
    
    // called by an observer on the tabViewModel's current selection property, to update tab and segmented control to current selection.
    
    func updateSelection(_ selnum: Int) {
        
        // printLog("WorkpageTabsView: updateSelection(): observed change on model triggered this to update tab and segmented control selection to \(selnum).")
        
        let numtabs = super.tabViewItems.count
        
        if selnum < numtabs {
            
            super.selectTabViewItem(at: selnum)
            
            updateSegmentToMatchTabViewSelection()
        }
    }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        let context = unsafeBitCast(NSGraphicsContext.current!.graphicsPort, to: CGContext.self)
        
        context.saveGState()
        
        // Pain the entire area in the background colour of the main panel
        // and then overlay a rectangle with a large 'hole' in the middle which
        // casts a shadow on this background. As to make the bezel.
        //
        context.setFillColor(backgroundColor.cgColor)
        context.fill(self.bounds)
        
        let frame = self.bounds
        let inside = self.bounds
        
        // We inset the hole by roughly half the hight of the selection bar at the
        // top - with a bit of movement down as to make it look optically pleasing
        // around the shadow cast by the bar itself.
        //
        //        let S : CGFloat = kSegHeight / 2;
        //    inside.origin.x += S/2;
        //    inside.origin.y += S/2 + 2.0;
        //    inside.size.width -= S;
        //    inside.size.height -= S;
        
        context.setStrokeColor(bezelColor.cgColor)
        context.setFillColor(windowBackgroundColor.cgColor)
        
      //  context.saveGState()
        
//        self.shadow = NSShadow();
//        self.shadow?.shadowColor = bezelColor
//        self.shadow?.shadowBlurRadius = 3
//        self.shadow?.shadowOffset = NSMakeSize(1,-1)
//        self.shadow?.set()
        
        //    let roundedRectPath = newPathForRoundedRect(inside, radius:kRadius)
        //    CGContextAddPath(context, roundedRectPath)
        
        let rectPath = CGPath(rect: inside, transform: nil)
        
        context.addPath(rectPath)
        CGContextAddReverseRect(context, frame: frame)
        
        context.closePath()
        context.fillPath()
        
        // The rounded textured style is semi translucent; so we
        // need to paint a bit of background behind it as to avoid
        // the bezel shining through. We also acknowledge that
        // it has round edges here.
        
        var barFrame = segmentedControl.frame
        barFrame.origin.x += 2.0
        barFrame.origin.y += 2.0
        barFrame.size.width -= 4.0
        barFrame.size.height -= 5.0
        
        //   let barPath = newPathForRoundedRect(barFrame, radius: 2.0)
        let barPath = CGPath(rect: barFrame, transform: nil)
        
        context.addPath(barPath)
        context.closePath()
        context.fillPath()
        
        // Remove shadow again - and draw a very thin outline around it all.
        
//        self.shadow = nil
     //   context.restoreGState()
        
        context.addPath(rectPath) // roundedRectPath
        context.closePath()
        context.setLineWidth(0.2)
        context.strokePath()
        
        // and wipe the line behind the bezel again.
        
        context.addPath(barPath); context.closePath()
        context.fillPath()
        
        context.restoreGState()
        
        super.draw(dirtyRect)
    }
    
    
    fileprivate func updateSegmentToMatchTabViewSelection() {
        
        if let selectedItem = selectedTabViewItem {
            
            segmentedControl.selectedSegment = indexOfTabViewItem(selectedItem)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        
        // printLog("WorkpageTabsView: mouseDown()")

    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
}






