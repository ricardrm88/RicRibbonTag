//
//  RicRibbonTag.swift
//
//  MIT License
//
//  Copyright (c) 2016 Ricard Romeo Murgó (https://github.com/ricardrm88)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Foundation

/// A ribbon with messages used to wrap views.
public class RicRibbon: CAShapeLayer, RicRibbonLabelProtocol {
    
     /// The label displayed in the ribbon.
    public var label: RicRibbonLabel!
    
    private var wrappedView: UIView!
    private var maskView: UIView!
    
    private var maskLayer = CAShapeLayer()
    private var decorationLayer: CAShapeLayer!
    private var decorationShadowLayer: CAShapeLayer!
    private var decorationLayer2: CAShapeLayer!
    private var decorationShadowLayer2: CAShapeLayer!
    
    private var ribbonPoints = Array<CGPoint>()
    
    private var horizontalOffset: CGFloat = 0.0
    private var offset: CGFloat = 10.0
    private var stripeWidth: CGFloat = 0.0
    private var stripeSpaceWidth: CGFloat = 0.0
    private var angle: CGFloat = 0.0
    
     /// The size of the decorations added outside of the view.
    public var decorationSize: CGFloat = 18.0 {
        didSet{ renderRibbon() }
    }
    
     /// The width of the ribbon.
    public var ribbonWidth: CGFloat = 20.0 {
        didSet{ renderRibbon() }
    }
    
     /// The color of the ribbon.
    public var ribbonColor: CGColor = UIColor.init(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0).CGColor {
        didSet{ renderRibbon() }
    }
    
     /// The color of the margin around the ribbon, if any.
    public var marginColor: CGColor = UIColor.init(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0).CGColor {
        didSet{ renderRibbon() }
    }
    
     /// The width of the margin around the ribbon.
    public var marginWidth: CGFloat = 0.0 {
        didSet{ renderRibbon() }
    }
    
     /// The distance between the origin corner point and the point of the ribbon closer to it.
    public var originDistance: CGFloat = 50.0 {
        didSet{ renderRibbon() }
    }
    
     /// The length of the ribbon in Right, Left and Top ribbons.
    public var ribbonLength: CGFloat = 100.0 {
        didSet{ renderRibbon() }
    }
    
     /// If true the ribbon and the origin may be modyfied to keep the whole ribbon in bounds.
    public var keepInBounds: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// If true the ribbon may move horizontally if it's taller than the view containing it.
    public var movesHorizontally: Bool = false {
        didSet { renderRibbon() }
    }
    
     /// Displays a shadow below the ribbon if true.
    public var usesShadow: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// Displays decorators outside the parent view if true.
    public var displayDecorators: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// The type of ribbon that will render.
    public var type = RibbonType.TopLeftCorner {
        didSet { renderRibbon() }
    }
    
     /// Added padding to ribbon when ribbon is autoresized.
    public var autoresizePadding: CGFloat = 10.0 {
        didSet { renderRibbon() }
    }
    
     /// When true the ribbon will autoresize to wrap it's content.
    public var autoresizes: Bool = false {
        didSet {
            setSizeToFit()
            renderRibbon()
        }
    }
    
    // MARK: Init methods
    
    /**
     Initializes a new ribbon with a given layer.
     
     - Parameters:
     - layer: The given layer for the ribbon
     
     - Returns: An initialized ribbon.
     */
    public override init(layer: AnyObject) {
        super.init()
        initializeUI()
    }
    
    /**
     Initializes a new ribbon.
     
     - Returns: An initialized ribbon.
     */
    public override init() {
        super.init()
        initializeUI()
    }
    
    /**
     Initializes a new ribbon with a given NSCoder.
     
     - Parameters:
     - aDecoder: The given coder for the ribbon
     
     - Returns: An initialized ribbon.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initializeUI(){
        self.label = RicRibbonLabel()
        label.delegate = self
        label.lineBreakMode = .ByClipping
        label.textAlignment = .Center
        label.numberOfLines = 0
        
        marginWidth = 1
    }
    
    // MARK: Parent methods
    
    override public func awakeFromNib() {
        initializeUI()
    }
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        renderRibbon()
    }
    
    // MARK: Public methods
    
    /**
     Surrounds an UIView with the current ribbon.
     
     @param view UIView that will be surrounded by the ribbon.
     */
    public func wrap(view: UIView) {
        view.layer.insertSublayer(self, atIndex: 0)
        
        //maskView = UIView(frame: view.bounds)
        maskView = UIView(frame: CGRect(x: -decorationSize, y: -decorationSize, width: view.bounds.width + decorationSize*2, height: view.bounds.height + decorationSize*2))
        maskView.clipsToBounds = true
        view.addSubview(maskView)
        maskView.addSubview(label)
        self.wrappedView = view
        renderRibbon()
        setSizeToFit()
        
        applyMasks()
    }
    
    /**
     Sets a dashed pattern around the ribbon edges.
     
     @param lineWidth width of the dashed pattern.
     @param spaceWidth space between stripes.
     */
    public func setDashPattern(lineWidth: CGFloat, spaceWidth: CGFloat){
        stripeWidth = lineWidth
        stripeSpaceWidth = spaceWidth
    }
    
    // MARK: Render methods
    
    private func renderRibbon(){
        let path = CGPathCreateMutable()
        
        if let frame = wrappedView?.frame {
            let hDistance = keepInBounds ? distanceForBounds(frame.size.width) : originDistance
            let vDistance = keepInBounds ? distanceForBounds(frame.size.height) : originDistance
            
            let distance =  min(hDistance, vDistance)
            
            calcPoints(distance)
            setTransformForDistance(distance)
            
            if ribbonPoints.count > 0 {
                CGPathMoveToPoint(path, nil, ribbonPoints[0].x, ribbonPoints[0].y)
            }
            
            for i in 0 ..< ribbonPoints.count {
                let pos = (i + 1) % ribbonPoints.count
                CGPathAddLineToPoint(path, nil, ribbonPoints[pos].x, ribbonPoints[pos].y)
            }
            
            configureShape(with: path)
            
            if displayDecorators {
                if movesHorizontally {
                    print("Decorations not available for movesHorizontally property enabled, waiting for " +
                        "https://github.com/ricardrm88/RicRibbonTag/issues/4")
                } else {
                    renderDecoration()
                }
            }
        }
    }
    
    private func renderDecoration(){
        switch type {
        case .TopLeftCorner, .TopRightCorner, .BottomLeftCorner, .BottomRightCorner:
            renderCornerDecoration()
        case .Left, .Right, .Top:
            renderEdgeDecoration()
        }
        
    }
    
    private func renderCornerDecoration() {
        //init
        let decorationOffset:CGFloat = type == .TopRightCorner || type == .BottomRightCorner ? -decorationSize : decorationSize
        
        decorationLayer = configShapeLayerIfNeeded(decorationLayer)
        decorationShadowLayer = configShapeLayerIfNeeded(decorationShadowLayer)
        decorationLayer2 = configShapeLayerIfNeeded(decorationLayer2)
        decorationShadowLayer2 = configShapeLayerIfNeeded(decorationShadowLayer2)
        
        //First decoration layer
        var points = [CGPoint(x: ribbonPoints[0].x + decorationOffset, y: -decorationSize),
                      CGPoint(x: ribbonPoints[1].x + decorationOffset, y: -decorationSize),
                      CGPoint(x: ribbonPoints[1].x, y: marginWidth),
                      CGPoint(x: ribbonPoints[0].x, y: marginWidth)]
        
        if type == .BottomRightCorner || type == .BottomLeftCorner {
            points = points.map(flipVertically)
        }
        
        configDecorationLayerUI(decorationLayer, path: pointsToPath(points))
        
        //First shadow layer
        var shadowPoints = [CGPoint(x: ribbonPoints[1].x + decorationOffset, y: -decorationSize),
                            CGPoint(x: ribbonPoints[1].x + decorationOffset - decorationOffset/5, y: marginWidth),
                            CGPoint(x: ribbonPoints[1].x, y: marginWidth)]
        
        if type == .BottomRightCorner || type == .BottomLeftCorner {
            shadowPoints = shadowPoints.map(flipVertically)
        }
        
        configShadowLayerUI(decorationShadowLayer, path: pointsToPath(shadowPoints))
        
        var vDecorationOffset = decorationOffset
        if type == .BottomLeftCorner || type == .TopRightCorner {
            vDecorationOffset = -decorationOffset
        }
        
        //Second decoration layer
        if ribbonPoints.count > 3 {
            let last = ribbonPoints[ribbonPoints.count - 3]
            let points2 = [CGPoint(x: last.x, y: last.y),
                           CGPoint(x: last.x - decorationOffset, y: last.y + vDecorationOffset),
                           CGPoint(x: last.x - decorationOffset, y: ribbonPoints[ribbonPoints.count - 2].y + vDecorationOffset),
                           CGPoint(x: last.x, y: ribbonPoints[ribbonPoints.count - 2].y)]
            
            configDecorationLayerUI(decorationLayer2, path: pointsToPath(points2))
        }
        
        //Second shadow layer
        let shadowPoints2 = [CGPoint(x: ribbonPoints[2].x - decorationOffset, y: ribbonPoints[2].y + vDecorationOffset),
                             CGPoint(x: ribbonPoints[2].x, y: ribbonPoints[2].y + vDecorationOffset*4/5),
                             CGPoint(x: ribbonPoints[2].x, y: ribbonPoints[2].y)]
        
        configShadowLayerUI(decorationShadowLayer2, path: pointsToPath(shadowPoints2))
    }
    
    private func renderEdgeDecoration() {
        if type == .Right || type == .Left{
            
            let offset = type == .Right ? decorationSize : -decorationSize
            
            decorationLayer = configShapeLayerIfNeeded(decorationLayer)
            decorationShadowLayer = configShapeLayerIfNeeded(decorationShadowLayer)
            
            let points = [CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y),
                          CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[0].y),
                          CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[1].y),
                          CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[1].y)]
            
            configDecorationLayerUI(decorationLayer, path: pointsToPath(points))
            
            //shadow
            let shadowPoints = [CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[0].y),
                                CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y - abs(offset*4/5)),
                                CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y)]
            
            configShadowLayerUI(decorationShadowLayer, path: pointsToPath(shadowPoints))
        } else if type == .Top{
            decorationLayer = configShapeLayerIfNeeded(decorationLayer)
            decorationShadowLayer = configShapeLayerIfNeeded(decorationShadowLayer)
            
            let points = [CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y + marginWidth/2),
                          CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y - decorationSize),
                          CGPoint(x: ribbonPoints[1].x, y: ribbonPoints[1].y - decorationSize),
                          CGPoint(x: ribbonPoints[1].x, y: ribbonPoints[1].y + marginWidth/2)]
            
            configDecorationLayerUI(decorationLayer, path: pointsToPath(points))
            
            //shadow
            let shadowPoints = [CGPoint(x: ribbonPoints[1].x, y: ribbonPoints[0].y  - decorationSize),
                                CGPoint(x: ribbonPoints[1].x + abs(decorationSize*4/5), y: ribbonPoints[0].y),
                                CGPoint(x: ribbonPoints[1].x, y: ribbonPoints[0].y + marginWidth/2)]
            configShadowLayerUI(decorationShadowLayer, path: pointsToPath(shadowPoints))
        }
    }
    
    private func calcPoints(distance: CGFloat) {
        ribbonPoints.removeAll()
        
        if let frame = wrappedView?.frame{
            switch self.type {
            case .TopLeftCorner, .TopRightCorner, .BottomLeftCorner, .BottomRightCorner:
                if horizontalOffset == 0 {
                    ribbonPoints.append(CGPoint(x: distance + marginWidth, y: marginWidth/2))
                    ribbonPoints.append(CGPoint(x: distance + ribbonWidth - marginWidth, y: marginWidth/2))
                    ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + ribbonWidth - marginWidth))
                    ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth))
                    ribbonPoints.append(CGPoint(x: distance + marginWidth, y: marginWidth/2))
                } else {
                    ribbonPoints.append(CGPoint(x: horizontalOffset + marginWidth, y: marginWidth/2))
                    ribbonPoints.append(CGPoint(x: horizontalOffset  + ribbonWidth - marginWidth, y: marginWidth/2))
                    ribbonPoints.append(CGPoint(x: marginWidth/2 + ribbonWidth, y: frame.height - marginWidth))
                    ribbonPoints.append(CGPoint(x: marginWidth/2, y: horizontalOffset + marginWidth))
                    ribbonPoints.append(CGPoint(x: horizontalOffset + marginWidth, y: marginWidth/2))
                }
            case .Left, .Right, .Top:
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2))
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2 + ribbonWidth))
                ribbonPoints.append(CGPoint(x: ribbonLength + marginWidth/2, y: distance + marginWidth/2 + ribbonWidth))
                ribbonPoints.append(CGPoint(x: ribbonLength + marginWidth/2, y: distance + marginWidth/2))
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2))
            }
            ribbonPoints = ribbonPoints.map({ (point: CGPoint) -> CGPoint in
                switch self.type {
                case .TopRightCorner, .Right:
                    return CGPoint(x: frame.width - point.x, y: point.y)
                case .BottomLeftCorner:
                    return CGPoint(x: point.x, y: frame.height - point.y)
                case .BottomRightCorner:
                    return CGPoint(x: frame.width - point.x, y: frame.height - point.y)
                case .Top:
                    return CGPoint(x: point.y, y: point.x)
                default:
                    return CGPoint(x: point.x, y: point.y)
                }
            })
        }
    }
    
    // MARK: UI methods
    
    private func applyMasks(){
        let maskPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(maskPath, nil, 0, wrappedView.frame.height)
        CGPathAddLineToPoint(maskPath, nil, wrappedView.frame.width, wrappedView.frame.height)
        CGPathAddLineToPoint(maskPath, nil, wrappedView.frame.width, 0)
        CGPathAddLineToPoint(maskPath, nil, 0, 0)
        CGPathAddLineToPoint(maskPath, nil, 0, wrappedView.frame.height)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        maskLayer.strokeColor = UIColor.redColor().CGColor
        
        self.mask = maskLayer
    }
    
    private func setSizeToFit() {
        label.sizeToFit()
        label.setNeedsLayout()
        label.setNeedsDisplay()
        label.layoutIfNeeded()
    }
    
    private func configureShape(with path: CGMutablePath) {
        self.path = path
        self.fillColor = ribbonColor
        self.lineWidth = marginWidth
        self.strokeColor = marginColor
        self.lineDashPattern = [stripeWidth, stripeSpaceWidth]
        
        if usesShadow {
            self.shadowOffset = CGSizeMake(0, 10)
            self.shadowRadius = 10.0
            self.shadowColor = UIColor.blackColor().CGColor
            self.shadowOpacity = 0.5
        } else {
            self.shadowOpacity = 0.0
        }
    }
    
    private func setTransformForDistance(distance: CGFloat) {
        label.transform = CGAffineTransformIdentity
        self.label.frame = CGRect(x: offset, y: distance, width: getLargeDistance(), height: ribbonWidth)
        
        let elements = CGFloat(ribbonPoints.count - 1)
        
        if ribbonPoints.count > 0 {
            let x = ribbonPoints.suffixFrom(1).reduce(0) { $0 + ($1.x / elements) }
            let y = ribbonPoints.suffixFrom(1).reduce(0) { $0 + ($1.y / elements) }
            label.center = CGPoint(x: x + decorationSize, y: y + decorationSize)
        }
        
        switch self.type {
        case .TopLeftCorner, .BottomRightCorner:
            angle = CGFloat(-M_PI/4)
            break
        case .TopRightCorner, .BottomLeftCorner:
            angle = CGFloat(M_PI/4)
            break
        case .Top:
            angle = CGFloat(M_PI/2)
            break
        default:
            break
        }
        
        label.transform = CGAffineTransformRotate(label.transform, angle)
    }
    
    // MARK: Util methods
    
    private func configShadowLayerUI(layer: CAShapeLayer, path: CGMutablePath) {
        layer.path = path
        layer.fillColor = UIColor.darkGrayColor().CGColor
    }
    
    private func configDecorationLayerUI(layer: CAShapeLayer, path: CGMutablePath) {
        layer.path = path
        layer.fillColor = ribbonColor
        layer.lineWidth = marginWidth
    }
    
    private func configShapeLayerIfNeeded(shapeLayer: CAShapeLayer?) -> CAShapeLayer{
        if let layer = shapeLayer {
            return layer
        } else {
            let layer = CAShapeLayer()
            wrappedView.layer.insertSublayer(layer, atIndex: 0)
            return layer
        }
    }
    
    private func pointsToPath(points: Array<CGPoint>) -> CGMutablePath{
        let path = CGPathCreateMutable()
        
        if points.count > 0 {
            CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
        }
        
        for i in 0 ..< points.count {
            let pos = (i + 1) % points.count
            CGPathAddLineToPoint(path, nil, points[pos].x, points[pos].y)
        }
        return path
    }
    
    private func flipVertically(point: CGPoint) -> CGPoint{
        return CGPoint(x: point.x, y: wrappedView.frame.height - point.y)
    }
    
    // MARK: Distance calc methods
    
    private func getLargeDistance() -> CGFloat{
        if ribbonPoints.count > 2{
            let xDist = (ribbonPoints[2].x - ribbonPoints[1].x);
            let yDist = (ribbonPoints[2].y - ribbonPoints[1].y);
            return sqrt((xDist * xDist) + (yDist * yDist));
        }
        return 0
    }
    
    private func getShortDistance() -> CGFloat{
        if ribbonPoints.count > 2{
            let xDist = (ribbonPoints[0].x - ribbonPoints[ribbonPoints.count - 2].x);
            let yDist = (ribbonPoints[0].y - ribbonPoints[ribbonPoints.count - 2].y);
            return sqrt((xDist * xDist) + (yDist * yDist));
        }
        return 0
    }
    
    private func distanceForBounds(parentSize: CGFloat) -> CGFloat {
        let ribbonWidth = self.ribbonWidth + autoresizePadding
        if movesHorizontally {
            if (originDistance + ribbonWidth) > parentSize {
                horizontalOffset = parentSize
            }
        } else {
            if ribbonWidth > parentSize {
                if self.ribbonWidth < parentSize {
                    autoresizePadding = parentSize - self.ribbonWidth
                } else {
                    self.ribbonWidth = parentSize - 1
                    autoresizePadding = 0
                }
                return 0
            } else  if (originDistance + ribbonWidth) > parentSize {
                return parentSize - ribbonWidth
            }
        }
        
        return originDistance
    }
    
    // MARK: Delegate methods
    
    /**
     This function is triggered when the label in the ribbon has been updated.
     
     @param sender label that has been updated.
     */
    public func ribbonLabelUpdatedLayout(sender: RicRibbonLabel) {
        if autoresizes {
            switch self.type {
            case .TopLeftCorner, .BottomRightCorner, .TopRightCorner, .BottomLeftCorner, .Left, .Right:
                ribbonWidth = sender.bounds.height + autoresizePadding
                break
            case .Top:
                ribbonWidth = sender.frame.width + autoresizePadding
                break
            }
        }
    }
}

/**
 Ribbon style type.
 
 - TopLeftCorner: Displays the ribbon at the top left corner of the view.
 - TopRightCorner: Displays the ribbon at the top right corner of the view.
 - BottomLeftCorner: Displays the ribbon at the bottom left corner of the view.
 - BottomRightCorner: Displays the ribbon at the bottom right corner of the view.
 - Left: Displays the ribbon at the left side of the view.
 - Right: Displays the ribbon at the right of the view.
 - Top: Displays the ribbon at the top of the view.
 */
public enum RibbonType {
    case TopLeftCorner
    case TopRightCorner
    case BottomLeftCorner
    case BottomRightCorner
    case Left
    case Right
    case Top
}