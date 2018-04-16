//
//  NeonViewExtensions.swift
//  ReactiveController
//
//  Created by Thom Jordan on 10/24/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import Cocoa

import Cocoa
typealias View = NSView


// MARK: UIView implementation of the Neon protocols.
//
extension View : Frameable, Anchorable, Alignable, Groupable {
    public var superFrame: CGRect {
        guard let superview = superview else {
            return CGRect.zero
        }
        
        return superview.frame
    }
    
    public func setHeightAutomatically() {
        //self.sizeToFit()
    }
}


// MARK: CALayer implementation of the Neon protocols.
//
extension CALayer : Frameable, Anchorable, Alignable, Groupable {
    public var superFrame: CGRect {
        guard let superlayer = superlayer else {
            return CGRect.zero
        }
        
        return superlayer.frame
    }
    
    public func setHeightAutomatically() { /* no-op here as this shouldn't apply to CALayers */ }
}


// MARK: AutoHeight
//
///
/// `CGFloat` constant used to specify that you want the height to be automatically calculated
/// using `sizeToFit()`.
///
public let AutoHeight : CGFloat = 0 // -1  // 0


// MARK: Corner
//
///
/// Specifies a corner of a frame.
///
/// **TopLeft**: The upper-left corner of the frame.
///
/// **TopRight**: The upper-right corner of the frame.
///
/// **BottomLeft**: The bottom-left corner of the frame.
///
/// **BottomRight**: The upper-right corner of the frame.
///
public enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}


// MARK: Edge
//
///
/// Specifies an edge, or face, of a frame.
///
/// **Top**: The top edge of the frame.
///
/// **Left**: The left edge of the frame.
///
/// **Bottom**: The bottom edge of the frame.
///
/// **Right**: The right edge of the frame.
///
public enum Edge {
    case top
    case left
    case bottom
    case right
}


// MARK: Align Type
//
///
/// Specifies how a view will be aligned relative to the sibling view.
///
/// **ToTheRightMatchingTop**: Specifies that the view should be aligned to the right of a sibling, matching the
/// top, or y origin, of the sibling's frame.
///
/// **ToTheRightMatchingBottom**: Specifies that the view should be aligned to the right of a sibling, matching
/// the bottom, or max y value, of the sibling's frame.
///
/// **ToTheRightCentered**: Specifies that the view should be aligned to the right of a sibling, and will be centered
/// to either match the vertical center of the sibling's frame or centered vertically within the superview, depending
/// on the context.
///
/// **ToTheLeftMatchingTop**: Specifies that the view should be aligned to the left of a sibling, matching the top,
/// or y origin, of the sibling's frame.
///
/// **ToTheLeftMatchingBottom**: Specifies that the view should be aligned to the left of a sibling, matching the
/// bottom, or max y value, of the sibling's frame.
///
/// **ToTheLeftCentered**: Specifies that the view should be aligned to the left of a sibling, and will be centered
/// to either match the vertical center of the sibling's frame or centered vertically within the superview, depending
/// on the context.
///
/// **UnderMatchingLeft**: Specifies that the view should be aligned under a sibling, matching the left, or x origin,
/// of the sibling's frame.
///
/// **UnderMatchingRight**: Specifies that the view should be aligned under a sibling, matching the right, or max y
/// of the sibling's frame.
///
/// **UnderCentered**: Specifies that the view should be aligned under a sibling, and will be centered to either match
/// the horizontal center of the sibling's frame or centered horizontally within the superview, depending on the context.
///
/// **AboveMatchingLeft**: Specifies that the view should be aligned above a sibling, matching the left, or x origin
/// of the sibling's frame.
///
/// **AboveMatchingRight**: Specifies that the view should be aligned above a sibling, matching the right, or max x
/// of the sibling's frame.
///
/// **AboveCentered**: Specifies that the view should be aligned above a sibling, and will be centered to either match
/// the horizontal center of the sibling's frame or centered horizontally within the superview, depending on the context.
///
public enum Align {
    case toTheRightMatchingTop
    case toTheRightMatchingBottom
    case toTheRightCentered
    case toTheLeftMatchingTop
    case toTheLeftMatchingBottom
    case toTheLeftCentered
    case underMatchingLeft
    case underMatchingRight
    case underCentered
    case aboveMatchingLeft
    case aboveMatchingRight
    case aboveCentered
}


// MARK: Group Type
//
///
/// Specifies how a group will be laid out.
///
/// **Horizontal**: Specifies that the views should be aligned relative to eachother horizontally.
///
/// **Vertical**: Specifies that the views should be aligned relative to eachother vertically.
///
public enum Group {
    case horizontal
    case vertical
}

/// Types adopting the `Frameable` protocol calculate specific `frame` information, as well as provide the
/// frame information about their `superview` or `superlayer`.
///
public protocol Frameable : class {
    
    var frame: CGRect { get set }
    var superFrame: CGRect { get }
    
    /// Get the x origin of a view.
    ///
    /// - returns: The minimum x value of the view's frame.
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.x() // returns 10.0
    ///
    var x: CGFloat { get }
    
    
    /// Get the mid x of a view.
    ///
    /// - returns: The middle x value of the view's frame
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.midX() // returns 7.5
    ///
    var xMid: CGFloat { get }
    
    
    /// Get the max x of a view.
    ///
    /// - returns: The maximum x value of the view's frame
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.maxX() // returns 15.0
    ///
    var xMax: CGFloat { get }
    
    
    /// Get the y origin of a view.
    ///
    /// - returns: The minimum y value of the view's frame.
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.y() // returns 20.0
    ///
    var y: CGFloat { get }
    
    
    /// Get the mid y of a view.
    ///
    /// - returns: The middle y value of the view's frame
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.midY() // returns 13.5
    ///
    var yMid: CGFloat { get }
    
    
    /// Get the max y of a view.
    ///
    /// - returns: The maximum y value of the view's frame.
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.maxY() // returns 27.0
    ///
    var yMax: CGFloat { get }
    
    
    /// Get the width of a view.
    ///
    /// - returns: The width of the view's frame.
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.width() // returns 5.0
    ///
    var width: CGFloat { get }
    
    
    /// Get the height of a view.
    ///
    /// - returns: The height of the view's frame.
    ///
    /// Example
    /// -------
    ///     let frame = CGRectMake(10.0, 20.0, 5.0, 7.0)
    ///     frame.height() // returns 7.0
    ///
    var height: CGFloat { get }
    
    
    /// *To be used internally* TODO: Determine how to make this either private or internal.
    ///
    ///
    func setHeightAutomatically()
}


extension Frameable {
    
    public var x: CGFloat {
        return frame.minX
    }
    
    public  var xMid: CGFloat {
        return frame.minX + (frame.width / 2.0)
    }
    
    public var xMax: CGFloat {
        return frame.maxX
    }
    
    public var y: CGFloat {
        return frame.minY
    }
    
    public var yMid: CGFloat {
        return frame.minY + (frame.height / 2.0)
    }
    
    public var yMax: CGFloat {
        return frame.maxY
    }
    
    public var width: CGFloat {
        return frame.width
    }
    
    public var height: CGFloat {
        return frame.height
    }
}

// Anchorable

public protocol Anchorable : Frameable {}

public extension Anchorable {
    
    /// Fill the superview, with optional padding values.
    ///
    /// - note: If you don't want padding, simply call `fillSuperview()` with no parameters.
    ///
    /// - parameters:
    ///   - left: The padding between the left side of the view and the superview.
    ///
    ///   - right: The padding between the right side of the view and the superview.
    ///
    ///   - top: The padding between the top of the view and the superview.
    ///
    ///   - bottom: The padding between the bottom of the view and the superview.
    ///
    public func fillSuperview(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        let width : CGFloat = superFrame.width - (left + right)
        let height : CGFloat = superFrame.height - (top + bottom)
        
        frame = CGRect(x: left, y: top, width: width, height: height)
    }
    
    
    /// Anchor a view in the center of its superview.
    ///
    /// - parameters:
    ///   - width: The width of the view.
    ///
    ///   - height: The height of the view.
    ///
    public func anchorInCenter(width: CGFloat, height: CGFloat) {
        let xOrigin : CGFloat = (superFrame.width / 2.0) - (width / 2.0)
        let yOrigin : CGFloat = (superFrame.height / 2.0) - (height / 2.0)
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.anchorInCenter(width: width, height: self.height)
        }
    }
    
    
    /// Anchor a view in one of the four corners of its superview.
    ///
    /// - parameters:
    ///   - corner: The `CornerType` value used to specify in which corner the view will be anchored.
    ///
    ///   - xPad: The *horizontal* padding applied to the view inside its superview, which can be applied
    /// to the left or right side of the view, depending upon the `CornerType` specified.
    ///
    ///   - yPad: The *vertical* padding applied to the view inside its supeview, which will either be on
    /// the top or bottom of the view, depending upon the `CornerType` specified.
    ///
    ///   - width: The width of the view.
    ///
    ///   - height: The height of the view.
    ///
    public func anchorInCorner(_ corner: Corner, xPad: CGFloat, yPad: CGFloat, width: CGFloat, height: CGFloat) {
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        
        switch corner {
        case .bottomLeft:
            xOrigin = xPad
            yOrigin = yPad
            
        case .topLeft:
            xOrigin = xPad
            yOrigin = superFrame.height - height - yPad
            
        case .bottomRight:
            xOrigin = superFrame.width - width - xPad
            yOrigin = yPad
            
        case .topRight:
            xOrigin = superFrame.width - width - xPad
            yOrigin = superFrame.height - height - yPad
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.anchorInCorner(corner, xPad: xPad, yPad: yPad, width: width, height: self.height)
        }
    }
    
    
    /// Anchor a view in its superview, centered on a given edge.
    ///
    /// - parameters:
    ///   - edge: The `Edge` used to specify which face of the superview the view
    /// will be anchored against and centered relative to.
    ///
    ///   - padding: The padding applied to the view inside its superview. How this padding is applied
    /// will vary depending on the `Edge` provided. Views centered against the top or bottom of
    /// their superview will have the padding applied above or below them respectively, whereas views
    /// centered against the left or right side of their superview will have the padding applied to the
    /// right and left sides respectively.
    ///
    ///   - width: The width of the view.
    ///
    ///   - height: The height of the view.
    ///
    public func anchorToEdge(_ edge: Edge, padding: CGFloat, width: CGFloat, height: CGFloat) {
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        
        switch edge {
        case .bottom:
            xOrigin = (superFrame.width / 2.0) - (width / 2.0)
            yOrigin = padding
            
        case .left:
            xOrigin = padding
            yOrigin = (superFrame.height / 2.0) - (height / 2.0)
            
        case .top:
            xOrigin = (superFrame.width / 2.0) - (width / 2.0)
            yOrigin = superFrame.height - height - padding
            
        case .right:
            xOrigin = superFrame.width - width - padding
            yOrigin = (superFrame.height / 2.0) - (height / 2.0)
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.anchorToEdge(edge, padding: padding, width: width, height: self.height)
        }
    }
    
    
    /// Anchor a view in its superview, centered on a given edge and filling either the width or
    /// height of that edge. For example, views anchored to the `.Top` or `.Bottom` will have
    /// their widths automatically sized to fill their superview, with the xPad applied to both
    /// the left and right sides of the view.
    ///
    /// - parameters:
    ///   - edge: The `Edge` used to specify which face of the superview the view
    /// will be anchored against, centered relative to, and expanded to fill.
    ///
    ///   - xPad: The horizontal padding applied to the view inside its superview. If the `Edge`
    /// specified is `.Top` or `.Bottom`, this padding will be applied to the left and right sides
    /// of the view when it fills the width superview.
    ///
    ///   - yPad: The vertical padding applied to the view inside its superview. If the `Edge`
    /// specified is `.Left` or `.Right`, this padding will be applied to the top and bottom sides
    /// of the view when it fills the height of the superview.
    ///
    ///   - otherSize: The size parameter that is *not automatically calculated* based on the provided
    /// edge. For example, views anchored to the `.Top` or `.Bottom` will have their widths automatically
    /// calculated, so `otherSize` will be applied to their height, and subsequently views anchored to
    /// the `.Left` and `.Right` will have `otherSize` applied to their width as their heights are
    /// automatically calculated.
    ///
    public func anchorAndFillEdge(_ edge: Edge, xPad: CGFloat, yPad: CGFloat, otherSize: CGFloat) {
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0
        var autoSize : Bool = false
        
        switch edge {
        case .bottom:
            xOrigin = xPad
            yOrigin = yPad
            width = superFrame.width - (2 * xPad)
            height = otherSize
            autoSize = true
            
        case .left:
            xOrigin = xPad
            yOrigin = yPad
            width = otherSize
            height = superFrame.height - (2 * yPad)
            
        case .top:
            xOrigin = xPad
            yOrigin = superFrame.height - otherSize - yPad
            width = superFrame.width - (2 * xPad)
            height = otherSize
            autoSize = true
            
        case .right:
            xOrigin = superFrame.width - otherSize - xPad
            yOrigin = yPad
            width = otherSize
            height = superFrame.height - (2 * yPad)
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight && autoSize {
            self.setHeightAutomatically()
            self.anchorAndFillEdge(edge, xPad: xPad, yPad: yPad, otherSize: self.height)
        }
    }
}


// Alignable

public protocol Alignable : Frameable {}

public extension Alignable {
    
    /// Align a view relative to a sibling view in the same superview.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with its sibling.
    ///
    ///   - relativeTo: The sibling view this view will be aligned relative to. **NOTE:** Ensure this sibling view shares
    /// the same superview as this view, and that the sibling view is not the same as this view, otherwise a
    /// `fatalError` is thrown.
    ///
    ///   - padding: The padding to be applied between this view and the sibling view, which is applied differently
    /// depending on the `Align` specified. For example, if aligning `.ToTheRightOfMatchingTop` the padding is used
    /// to adjust the x origin of this view so it sits to the right of the sibling view, while the y origin is
    /// automatically calculated to match the sibling view.
    ///
    ///   - width: The width of the view.
    ///
    ///   - height: The height of the view.
    ///
    public func align(_ align: Align, relativeTo sibling: Frameable, padding: CGFloat, width: CGFloat, height: CGFloat) {
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        
        switch align {
        case .toTheRightMatchingTop:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMax - height   // y
            
        case .toTheRightMatchingBottom:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y               // yMax - height
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMid - (height / 2.0)
            
        case .toTheLeftMatchingTop:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.yMax - height    // y
            
        case .toTheLeftMatchingBottom:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.y                //  yMax - height
            
        case .toTheLeftCentered:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.yMid - (height / 2.0)
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.y - padding - height   // yMax + padding
            
        case .underMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = sibling.y - padding - height   // yMax + padding
            
        case .underCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = sibling.y - padding - height   // yMax + padding
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding         // y - padding - height
            
        case .aboveMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = sibling.yMax + padding         // y - padding - height
            
        case .aboveCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = sibling.yMax + padding         // y - padding - height
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.align(align, relativeTo: sibling, padding: padding, width: width, height: self.height)
        }
    }
    
    
    
    /// Align a view relative to a sibling view in the same superview, and automatically expand the width to fill
    /// the superview with equal padding between the superview and sibling view.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with its sibling.
    ///
    ///   - relativeTo: The sibling view this view will be aligned relative to. **NOTE:** Ensure this sibling view shares
    /// the same superview as this view, and that the sibling view is not the same as this view, otherwise a
    /// `fatalError` is thrown.
    ///
    ///   - padding: The padding to be applied between this view, the sibling view and the superview.
    ///
    ///   - height: The height of the view.
    ///
    public func alignAndFillWidth(align: Align, relativeTo sibling: Frameable, padding: CGFloat, height: CGFloat) {
        let superviewWidth = superFrame.width
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var width : CGFloat = 0.0
        
        switch align {
        case .toTheRightMatchingTop:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMax - height    // y
            width = superviewWidth - xOrigin - padding
            
        case .toTheRightMatchingBottom:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y                // yMax - height
            width = superviewWidth - xOrigin - padding
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMid - (height / 2.0)
            width = superviewWidth - xOrigin - padding
            
        case .toTheLeftMatchingTop:
            xOrigin = padding
            yOrigin = sibling.yMax - height    // y
            width = sibling.x - (2 * padding)
            
        case .toTheLeftMatchingBottom:
            xOrigin = padding
            yOrigin = sibling.y                // yMax - height
            width = sibling.x - (2 * padding)
            
        case .toTheLeftCentered:
            xOrigin = padding
            yOrigin = sibling.yMid - (height / 2.0)
            width = sibling.x - (2 * padding)
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.y - padding - height // yMax + padding
            width = superviewWidth - xOrigin - padding
            
        case .underMatchingRight:
            xOrigin = padding
            yOrigin = sibling.y - padding - height // yMax + padding
            width = superviewWidth - (superviewWidth - sibling.xMax) - padding
            
        case .underCentered:
            xOrigin = padding
            yOrigin = sibling.y - padding - height // yMax + padding
            width = superviewWidth - (2 * padding)
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding // y - padding - height
            width = superviewWidth - xOrigin - padding
            
        case .aboveMatchingRight:
            xOrigin = padding
            yOrigin = sibling.yMax + padding // y - padding - height
            width = superviewWidth - (superviewWidth - sibling.xMax) - padding
            
        case .aboveCentered:
            xOrigin = padding
            yOrigin = sibling.yMax + padding // y - padding - height
            width = superviewWidth - (2 * padding)
        }
        
        if width < 0.0 {
            width = 0.0
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.alignAndFillWidth(align: align, relativeTo: sibling, padding: padding, height: self.height)
        }
    }
    
    
    /// Align a view relative to a sibling view in the same superview, and automatically expand the height to fill
    /// the superview with equal padding between the superview and sibling view.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with its sibling.
    ///
    ///   - relativeTo: The sibling view this view will be aligned relative to. **NOTE:** Ensure this sibling view shares
    /// the same superview as this view, and that the sibling view is not the same as this view, otherwise a
    /// `fatalError` is thrown.
    ///
    ///   - padding: The padding to be applied between this view, the sibling view and the superview.
    ///
    ///   - width: The width of the view.
    ///
    public func alignAndFillHeight(align: Align, relativeTo sibling: Frameable, padding: CGFloat, width: CGFloat) {
        let superviewHeight : CGFloat = superFrame.height
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var height : CGFloat = 0.0
        
        switch align {
        case .toTheRightMatchingTop:
            xOrigin = sibling.xMax + padding
            yOrigin = padding // sibling.y
            height = superviewHeight - (superviewHeight - sibling.yMax) - padding // superviewHeight - sibling.y - padding
            
        case .toTheRightMatchingBottom:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y // padding
            height = superviewHeight - sibling.y - padding // superviewHeight - (superviewHeight - sibling.yMax) - padding
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = padding
            height = superviewHeight - (2 * padding)
            
        case .toTheLeftMatchingTop:
            xOrigin = sibling.x - width - padding
            yOrigin = padding // sibling.y
            height = superviewHeight - (superviewHeight - sibling.yMax) - padding // superviewHeight - sibling.y - padding
            
        case .toTheLeftMatchingBottom:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.y // padding
            height = superviewHeight - sibling.y - padding // superviewHeight - (superviewHeight - sibling.yMax) - padding
            
        case .toTheLeftCentered:
            xOrigin = sibling.x - width - padding
            yOrigin = padding
            height = superviewHeight - (2 * padding)
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = padding // sibling.yMax + padding
            height = sibling.y - (2 * padding) // superviewHeight - yOrigin - padding
            
        case .underMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = padding // sibling.yMax + padding
            height = sibling.y - (2 * padding) // superviewHeight - yOrigin - padding
            
        case .underCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = padding // sibling.yMax + padding
            height = sibling.y - (2 * padding) // superviewHeight - yOrigin - padding
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding // padding
            height = superviewHeight - yOrigin - padding // sibling.y - (2 * padding)
            
        case .aboveMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = sibling.yMax + padding // padding
            height = superviewHeight - yOrigin - padding // sibling.y - (2 * padding)
            
        case .aboveCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = sibling.yMax + padding // padding
            height = superviewHeight - yOrigin - padding // sibling.y - (2 * padding)
        }
        
        if height < 0.0 {
            height = 0.0
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }
    
    
    /// Align a view relative to a sibling view in the same superview, and automatically expand the width AND height
    /// to fill the superview with equal padding between the superview and sibling view.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with its sibling.
    ///
    ///   - relativeTo: The sibling view this view will be aligned relative to. **NOTE:** Ensure this sibling view shares
    /// the same superview as this view, and that the sibling view is not the same as this view, otherwise a
    /// `fatalError` is thrown.
    ///
    ///   - padding: The padding to be applied between this view, the sibling view and the superview.
    ///
    public func alignAndFill(align: Align, relativeTo sibling: Frameable, padding: CGFloat) {
        let superviewWidth : CGFloat = superFrame.width
        let superviewHeight : CGFloat = superFrame.height
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0
        
        switch align {
        case .toTheRightMatchingBottom:  // Top
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y
            width = superviewWidth - xOrigin - padding
            height = superviewHeight - yOrigin - padding
            
        case .toTheRightMatchingTop:    // Bottom
            xOrigin = sibling.xMax + padding
            yOrigin = padding
            width = superviewWidth - xOrigin - padding
            height = superviewHeight - (superviewHeight - sibling.yMax) - padding
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = padding
            width = superviewWidth - xOrigin - padding
            height = superviewHeight - (2 * padding)
            
        case .toTheLeftMatchingBottom:   // Top
            xOrigin = padding
            yOrigin = sibling.y
            width = superviewWidth - (superviewWidth - sibling.x) - (2 * padding)
            height = superviewHeight - yOrigin - padding
            
        case .toTheLeftMatchingTop :    // Bottom (and so on... (continuing below))
            xOrigin = padding
            yOrigin = padding
            width = superviewWidth - (superviewWidth - sibling.x) - (2 * padding)
            height = superviewHeight - (superviewHeight - sibling.yMax) - padding
            
        case .toTheLeftCentered:
            xOrigin = padding
            yOrigin = padding
            width = superviewWidth - (superviewWidth - sibling.x) - (2 * padding)
            height = superviewHeight - (2 * padding)
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding
            width = superviewWidth - xOrigin - padding
            height = superviewHeight - yOrigin - padding
            
        case .aboveMatchingRight:
            xOrigin = padding
            yOrigin = sibling.yMax + padding
            width = superviewWidth - (superviewWidth - sibling.xMax) - padding
            height = superviewHeight - yOrigin - padding
            
        case .aboveCentered:
            xOrigin = padding
            yOrigin = sibling.yMax + padding
            width = superviewWidth - (2 * padding)
            height = superviewHeight - yOrigin - padding
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = padding
            width = superviewWidth - xOrigin - padding
            height = superviewHeight - (superviewHeight - sibling.y) - (2 * padding)
            
        case .underMatchingRight:
            xOrigin = padding
            yOrigin = padding
            width = superviewWidth - (superviewWidth - sibling.xMax) - padding
            height = superviewHeight - (superviewHeight - sibling.y) - (2 * padding)
            
        case .underCentered:
            xOrigin = padding
            yOrigin = padding
            width = superviewWidth - (2 * padding)
            height = superviewHeight - (superviewHeight - sibling.y) - (2 * padding)
        }
        
        if width < 0.0 {
            width = 0.0
        }
        
        if height < 0.0 {
            height = 0.0
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }
    
    
    /// Align a view between two sibling views horizontally, automatically expanding the width to extend the full
    /// horizontal span between the `primaryView` and the `secondaryView`, with equal padding on both sides.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with the primary view.
    ///
    ///   - primaryView: The primary sibling view this view will be aligned relative to.
    ///
    ///   - secondaryView: The secondary sibling view this view will be automatically sized to fill the space between.
    ///
    ///   - padding: The horizontal padding to be applied between this view and both sibling views.
    ///
    ///   - height: The height of the view.
    ///
    public func alignBetweenHorizontal(align: Align, primaryView: Frameable, secondaryView: Frameable, padding: CGFloat, height: CGFloat) {
        let superviewWidth : CGFloat = superFrame.width
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var width : CGFloat = 0.0
        
        switch align {
        case .toTheRightMatchingBottom:
            xOrigin = primaryView.xMax + padding
            yOrigin = primaryView.y
            width = superviewWidth - primaryView.xMax - (superviewWidth - secondaryView.x) - (2 * padding)
            
        case .toTheRightMatchingTop:
            xOrigin = primaryView.xMax + padding
            yOrigin = primaryView.yMax - height
            width = superviewWidth - primaryView.xMax - (superviewWidth - secondaryView.x) - (2 * padding)
            
        case .toTheRightCentered:
            xOrigin = primaryView.xMax + padding
            yOrigin = primaryView.yMid - (height / 2.0)
            width = superviewWidth - primaryView.xMax - (superviewWidth - secondaryView.x) - (2 * padding)
            
        case .toTheLeftMatchingBottom:
            xOrigin = secondaryView.xMax + padding
            yOrigin = primaryView.y
            width = superviewWidth - secondaryView.xMax - (superviewWidth - primaryView.x) - (2 * padding)
            
        case .toTheLeftMatchingTop:
            xOrigin = secondaryView.xMax + padding
            yOrigin = primaryView.yMax - height
            width = superviewWidth - secondaryView.xMax - (superviewWidth - primaryView.x) - (2 * padding)
            
        case .toTheLeftCentered:
            xOrigin = secondaryView.xMax + padding
            yOrigin = primaryView.yMid - (height / 2.0)
            width = superviewWidth - secondaryView.xMax - (superviewWidth - primaryView.x) - (2 * padding)
            
        case .underMatchingLeft, .underMatchingRight, .underCentered,  .aboveMatchingLeft, .aboveMatchingRight, .aboveCentered:
            fatalError("[NEON] Invalid Align specified for alignBetweenHorizonal().")
        }
        
        if width < 0.0 {
            width = 0.0
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        if height == AutoHeight {
            self.setHeightAutomatically()
            self.alignBetweenHorizontal(align: align, primaryView: primaryView, secondaryView: secondaryView, padding: padding, height: self.height)
        }
    }
    
    
    /// Align a view between two sibling views vertically, automatically expanding the height to extend the full
    /// vertical span between the `primaryView` and the `secondaryView`, with equal padding above and below.
    ///
    /// - parameters:
    ///   - align: The `Align` type used to specify where and how this view is aligned with the primary view.
    ///
    ///   - primaryView: The primary sibling view this view will be aligned relative to.
    ///
    ///   - secondaryView: The secondary sibling view this view will be automatically sized to fill the space between.
    ///
    ///   - padding: The horizontal padding to be applied between this view and both sibling views.
    ///
    ///   - width: The width of the view.
    ///
    public func alignBetweenVertical(align: Align, primaryView: Frameable, secondaryView: Frameable, padding: CGFloat, width: CGFloat) {
        let superviewHeight : CGFloat = superFrame.height
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var height : CGFloat = 0.0
        
        switch align {
        case .aboveMatchingLeft:
            xOrigin = primaryView.x
            yOrigin = primaryView.yMax + padding
            height = superviewHeight - primaryView.yMax - (superviewHeight - secondaryView.y) - (2 * padding)
            
        case .aboveMatchingRight:
            xOrigin = primaryView.xMax - width
            yOrigin = primaryView.yMax + padding
            height = superviewHeight - primaryView.yMax - (superviewHeight - secondaryView.y) - (2 * padding)
            
        case .aboveCentered:
            xOrigin = primaryView.xMid - (width / 2.0)
            yOrigin = primaryView.yMax + padding
            height = superviewHeight - primaryView.yMax - (superviewHeight - secondaryView.y) - (2 * padding)
            
        case .underMatchingLeft:
            xOrigin = primaryView.x
            yOrigin = secondaryView.yMax + padding
            height = superviewHeight - secondaryView.yMax - (superviewHeight - primaryView.y) - (2 * padding)
            
        case .underMatchingRight:
            xOrigin = primaryView.xMax - width
            yOrigin = secondaryView.yMax + padding
            height = superviewHeight - secondaryView.yMax - (superviewHeight - primaryView.y) - (2 * padding)
            
        case .underCentered:
            xOrigin = primaryView.xMid - (width / 2.0)
            yOrigin = secondaryView.yMax + padding
            height = superviewHeight - secondaryView.yMax - (superviewHeight - primaryView.y) - (2 * padding)
            
        case .toTheLeftMatchingTop, .toTheLeftMatchingBottom, .toTheLeftCentered, .toTheRightMatchingTop, .toTheRightMatchingBottom, .toTheRightCentered:
            fatalError("[NEON] Invalid Align specified for alignBetweenVertical().")
        }
        
        if height < 0 {
            height = 0
        }
        
        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }
}


// Groupable


public protocol Groupable : Frameable {}

public extension Groupable {
    
    /// Tell a view to group an array of its subviews centered, specifying the padding between each subview,
    /// as well as the size of each.
    ///
    /// - parameters:
    ///   - group: The `Group` type specifying if the subviews will be laid out horizontally or vertically in the center.
    ///
    ///   - views: The array of views to grouped in the center. Depending on if the views are gouped horizontally
    /// or vertically, they will be positioned in order from left-to-right and top-to-bottom, respectively.
    ///
    ///   - padding: The padding to be applied between the subviews.
    ///
    ///   - width: The width of each subview.
    ///
    ///   - height: The height of each subview.
    ///
    public func groupInCenter(group: Group, views: [Frameable], padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupInCenter().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var xAdjust : CGFloat = 0.0
        var yAdjust : CGFloat = 0.0
        
        switch group {
        case .horizontal:
            xOrigin = (self.width - (CGFloat(views.count) * width) - (CGFloat(views.count - 1) * padding)) / 2.0
            yOrigin = (self.height / 2.0) - (height / 2.0)
            xAdjust = width + padding
            
        case .vertical:
            xOrigin = (self.width / 2.0) - (width / 2.0)
            yOrigin = (self.height - (CGFloat(views.count) * height) - (CGFloat(views.count - 1) * padding)) / 2.0
            yAdjust = height + padding
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            xOrigin += xAdjust
            yOrigin += yAdjust
        }
    }
    
    
    /// Tell a view to group an array of its subviews in one of its corners, specifying the padding between each subview,
    /// as well as the size of each.
    ///
    /// - parameters:
    ///   - group: The `Group` type specifying if the subviews will be laid out horizontally or vertically in the corner.
    ///
    ///   - views: The array of views to grouped in the specified corner. Depending on if the views are gouped horizontally
    /// or vertically, they will be positioned in order from left-to-right and top-to-bottom, respectively.
    ///
    ///   - inCorner: The specified corner the views will be grouped in.
    ///
    ///   - padding: The padding to be applied between the subviews and their superview.
    ///
    ///   - width: The width of each subview.
    ///
    ///   - height: The height of each subview.
    ///
    public func groupInCorner(group: Group, views: [Frameable], inCorner corner: Corner, padding: CGFloat, width: CGFloat, height: CGFloat) {
        switch group {
        case .horizontal:
            groupInCornerHorizontal(views, inCorner: corner, padding: padding, width: width, height: height)
            
        case .vertical:
            groupInCornerVertical(views, inCorner: corner, padding: padding, width: width, height: height)
        }
    }
    
    
    /// Tell a view to group an array of its subviews against one of its edges, specifying the padding between each subview
    /// and their superview, as well as the size of each.
    ///
    /// - parameters:
    ///   - group: The `Group` type specifying if the subviews will be laid out horizontally or vertically against the specified
    /// edge.
    ///
    ///   - views: The array of views to grouped against the spcified edge. Depending on if the views are gouped horizontally
    /// or vertically, they will be positioned in-order from left-to-right and top-to-bottom, respectively.
    ///
    ///   - againstEdge: The specified edge the views will be grouped against.
    ///
    ///   - padding: The padding to be applied between each of the subviews and their superview.
    ///
    ///   - width: The width of each subview.
    ///
    ///   - height: The height of each subview.
    ///
    public func groupAgainstEdge(group: Group, views: [Frameable], againstEdge edge: Edge, padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupAgainstEdge().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        var xAdjust : CGFloat = 0.0
        var yAdjust : CGFloat = 0.0
        
        switch edge {
        case .bottom:
            if group == .horizontal {
                xOrigin = (self.width - (CGFloat(views.count) * width) - (CGFloat(views.count - 1) * padding)) / 2.0
                xAdjust = width + padding
            } else {
                xOrigin = (self.width / 2.0) - (width / 2.0)
                yAdjust = height + padding
            }
            
            yOrigin = padding
            
        case .left:
            if group == .horizontal {
                yOrigin = (self.height / 2.0) - (height / 2.0)
                xAdjust = width + padding
            } else {
                yOrigin = (self.height - (CGFloat(views.count) * height) - (CGFloat(views.count - 1) * padding)) / 2.0
                yAdjust = height + padding
            }
            
            xOrigin = padding
            
        case .top:
            if group == .horizontal {
                xOrigin = (self.width - (CGFloat(views.count) * width) - (CGFloat(views.count - 1) * padding)) / 2.0
                yOrigin = self.height - height - padding
                xAdjust = width + padding
            } else {
                xOrigin = (self.width / 2.0) - (width / 2.0)
                yOrigin = self.height - (CGFloat(views.count) * height) - (CGFloat(views.count) * padding)
                yAdjust = height + padding
            }
            
        case .right:
            if group == .horizontal {
                xOrigin = self.width - (CGFloat(views.count) * width) - (CGFloat(views.count) * padding)
                yOrigin = (self.height / 2.0) - (height / 2.0)
                xAdjust = width + padding
            } else {
                xOrigin = self.width - width - padding
                yOrigin = (self.height - (CGFloat(views.count) * height) - (CGFloat(views.count - 1) * padding)) / 2.0
                yAdjust = height + padding
            }
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            xOrigin += xAdjust
            yOrigin += yAdjust
        }
    }
    
    
    /// Tell a view to group an array of its subviews relative to another of that view's subview, specifying the padding between
    /// each.
    ///
    /// - parameters:
    ///   - group: The `Group` type specifying if the subviews will be laid out horizontally or vertically against the specified
    /// sibling.
    ///
    ///   - andAlign: the `Align` type specifying how the views will be aligned relative to the sibling.
    ///
    ///   - views: The array of views to grouped against the sibling. Depending on if the views are gouped horizontally
    /// or vertically, they will be positioned in-order from left-to-right and top-to-bottom, respectively.
    ///
    ///   - relativeTo: The sibling view that the views will be aligned relative to.
    ///
    ///   - padding: The padding to be applied between each of the subviews and the sibling.
    ///
    ///   - width: The width of each subview.
    ///
    ///   - height: The height of each subview.
    ///
    public func groupAndAlign(group: Group, andAlign align: Align, views: [Frameable], relativeTo sibling: Frameable, padding: CGFloat, width: CGFloat, height: CGFloat) {
        switch group {
        case .horizontal:
            groupAndAlignHorizontal(align, views: views, relativeTo: sibling, padding: padding, width: width, height: height)
            
        case .vertical:
            groupAndAlignVertical(align, views: views, relativeTo: sibling, padding: padding, width: width, height: height)
        }
    }
    
    
    /// Tell a view to group an array of its subviews filling the width and height of the superview, specifying the padding between
    /// each subview and the superview.
    ///
    /// - parameters:
    ///   - group: The `Group` type specifying if the subviews will be laid out horizontally or vertically.
    ///
    ///   - views: The array of views to be grouped against the sibling. Depending on if the views are grouped horizontally
    /// or vertically, they will be positions in-order from left-to-right and top-to-bottom, respectively.
    ///
    ///   - padding: The padding to be applied between each of the subviews and the sibling.
    ///
    public func groupAndFill(group: Group, views: [Frameable], padding: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupAndFill().")
            return
        }
        
        var xOrigin : CGFloat = padding
        var yOrigin : CGFloat = padding
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0
        var xAdjust : CGFloat = 0.0
        var yAdjust : CGFloat = 0.0
        
        switch group {
        case .horizontal:
            width = (self.width - (CGFloat(views.count + 1) * padding)) / CGFloat(views.count)
            height = self.height - (2 * padding)
            xAdjust = width + padding
            
        case .vertical:
            width = self.width - (2 * padding)
            height = (self.height - (CGFloat(views.count + 1) * padding)) / CGFloat(views.count)
            yAdjust = height + padding
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            xOrigin += xAdjust
            yOrigin += yAdjust
        }
    }
    
    
    
    // MARK: Private utils
    //
    fileprivate func groupInCornerHorizontal(_ views: [Frameable], inCorner corner: Corner, padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupInCorner().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        let xAdjust : CGFloat = width + padding
        
        switch corner {
        case .bottomLeft:
            xOrigin = padding
            yOrigin = padding
            
        case .bottomRight:
            xOrigin = self.width - ((CGFloat(views.count) * width) + (CGFloat(views.count) * padding))
            yOrigin = padding
            
        case .topLeft:
            xOrigin = padding
            yOrigin = self.height - height - padding
            
        case .topRight:
            xOrigin = self.width - ((CGFloat(views.count) * width) + (CGFloat(views.count) * padding))
            yOrigin = self.height - height - padding
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            xOrigin += xAdjust
        }
    }
    
    fileprivate func groupInCornerVertical(_ views: [Frameable], inCorner corner: Corner, padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupInCorner().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        let yAdjust : CGFloat = height + padding
        
        switch corner {
        case .bottomLeft:
            xOrigin = padding
            yOrigin = padding
            
        case .bottomRight:
            xOrigin = self.width - width - padding
            yOrigin = padding
            
        case .topLeft:
            xOrigin = padding
            yOrigin = self.height - ((CGFloat(views.count) * height) + (CGFloat(views.count) * padding))
            
        case .topRight:
            xOrigin = self.width - width - padding
            yOrigin = self.height - ((CGFloat(views.count) * height) + (CGFloat(views.count) * padding))
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            yOrigin += yAdjust
        }
    }
    
    fileprivate func groupAndAlignHorizontal(_ align: Align, views: [Frameable], relativeTo sibling: Frameable, padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupAndAlign().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        let xAdjust : CGFloat = width + padding
        
        switch align {
        case .toTheRightMatchingBottom:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y
            
        case .toTheRightMatchingTop:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMax - height
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMid - (height / 2.0)
            
        case .toTheLeftMatchingBottom:
            xOrigin = sibling.x - (CGFloat(views.count) * width) - (CGFloat(views.count) * padding)
            yOrigin = sibling.y
            
        case .toTheLeftMatchingTop:
            xOrigin = sibling.x - (CGFloat(views.count) * width) - (CGFloat(views.count) * padding)
            yOrigin = sibling.yMax - height
            
        case .toTheLeftCentered:
            xOrigin = sibling.x - (CGFloat(views.count) * width) - (CGFloat(views.count) * padding)
            yOrigin = sibling.yMid - (height / 2.0)
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding
            
        case .aboveMatchingRight:
            xOrigin = sibling.xMax - (CGFloat(views.count) * width) - (CGFloat(views.count - 1) * padding)
            yOrigin = sibling.yMax + padding
            
        case .aboveCentered:
            xOrigin = sibling.xMid - ((CGFloat(views.count) * width) + (CGFloat(views.count - 1) * padding)) / 2.0
            yOrigin = sibling.yMax + padding
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.y - height - padding
            
        case .underMatchingRight:
            xOrigin = sibling.xMax - (CGFloat(views.count) * width) - (CGFloat(views.count - 1) * padding)
            yOrigin = sibling.y - height - padding
            
        case .underCentered:
            xOrigin = sibling.xMid - ((CGFloat(views.count) * width) + (CGFloat(views.count - 1) * padding)) / 2.0
            yOrigin = sibling.y - height - padding
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            xOrigin += xAdjust
        }
    }
    
    fileprivate func groupAndAlignVertical(_ align: Align, views: [Frameable], relativeTo sibling: Frameable, padding: CGFloat, width: CGFloat, height: CGFloat) {
        if views.count == 0 {
            print("[NEON] Warning: No subviews provided to groupAndAlign().")
            return
        }
        
        var xOrigin : CGFloat = 0.0
        var yOrigin : CGFloat = 0.0
        let yAdjust : CGFloat = height + padding
        
        switch align {
        case .toTheRightMatchingBottom:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.y
            
        case .toTheRightMatchingTop:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMax - (CGFloat(views.count) * height) - (CGFloat(views.count - 1) * padding)
            
        case .toTheRightCentered:
            xOrigin = sibling.xMax + padding
            yOrigin = sibling.yMid - ((CGFloat(views.count) * height) + CGFloat(views.count - 1) * padding) / 2.0
            
        case .toTheLeftMatchingBottom:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.y
            
        case .toTheLeftMatchingTop:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.yMax - (CGFloat(views.count) * height) - (CGFloat(views.count - 1) * padding)
            
        case .toTheLeftCentered:
            xOrigin = sibling.x - width - padding
            yOrigin = sibling.yMid - ((CGFloat(views.count) * height) + CGFloat(views.count - 1) * padding) / 2.0
            
        case .aboveMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.yMax + padding
            
        case .aboveMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = sibling.yMax + padding
            
        case .aboveCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = sibling.yMax + padding
            
        case .underMatchingLeft:
            xOrigin = sibling.x
            yOrigin = sibling.y - (CGFloat(views.count) * height) - (CGFloat(views.count) * padding)
            
        case .underMatchingRight:
            xOrigin = sibling.xMax - width
            yOrigin = sibling.y - (CGFloat(views.count) * height) - (CGFloat(views.count) * padding)
            
        case .underCentered:
            xOrigin = sibling.xMid - (width / 2.0)
            yOrigin = sibling.y - (CGFloat(views.count) * height) - (CGFloat(views.count) * padding)
        }
        
        for view in views {
            view.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
            
            yOrigin += yAdjust
        }
    }
}

