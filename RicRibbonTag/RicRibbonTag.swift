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
open class RicRibbon: CAShapeLayer, RicRibbonLabelProtocol {
    
     /// The label displayed in the ribbon.
    open var label: RicRibbonLabel!
    
    fileprivate var wrappedView: UIView!
    fileprivate var maskView: UIView!
    
    fileprivate var maskLayer = CAShapeLayer()
    fileprivate var decorationLayer: CAShapeLayer!
    fileprivate var decorationShadowLayer: CAShapeLayer!
    fileprivate var decorationLayer2: CAShapeLayer!
    fileprivate var decorationShadowLayer2: CAShapeLayer!
    
    fileprivate var ribbonPoints = Array<CGPoint>()
    
    fileprivate var horizontalOffset: CGFloat = 0.0
    fileprivate var offset: CGFloat = 10.0
    fileprivate var stripeWidth: CGFloat = 0.0
    fileprivate var stripeSpaceWidth: CGFloat = 0.0
    fileprivate var angle: CGFloat = 0.0
    
     /// The size of the decorations added outside of the view.
    open var decorationSize: CGFloat = 18.0 {
        didSet{ renderRibbon() }
    }
    
     /// The width of the ribbon.
    open var ribbonWidth: CGFloat = 20.0 {
        didSet{ renderRibbon() }
    }
    
     /// The color of the ribbon.
    open var ribbonColor: CGColor = UIColor.init(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0).cgColor {
        didSet{ renderRibbon() }
    }
    
     /// The color of the margin around the ribbon, if any.
    open var marginColor: CGColor = UIColor.init(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0).cgColor {
        didSet{ renderRibbon() }
    }
    
     /// The width of the margin around the ribbon.
    open var marginWidth: CGFloat = 0.0 {
        didSet{ renderRibbon() }
    }
    
     /// The distance between the origin corner point and the point of the ribbon closer to it.
    open var originDistance: CGFloat = 50.0 {
        didSet{ renderRibbon() }
    }
    
     /// The length of the ribbon in Right, Left and Top ribbons.
    open var ribbonLength: CGFloat = 100.0 {
        didSet{ renderRibbon() }
    }
    
     /// If true the ribbon and the origin may be modyfied to keep the whole ribbon in bounds.
    open var keepInBounds: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// If true the ribbon may move horizontally if it's taller than the view containing it.
    open var movesHorizontally: Bool = false {
        didSet { renderRibbon() }
    }
    
     /// Displays a shadow below the ribbon if true.
    open var usesShadow: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// Displays decorators outside the parent view if true.
    open var displayDecorators: Bool = true {
        didSet { renderRibbon() }
    }
    
     /// The type of ribbon that will render.
    open var type = RibbonType.topLeftCorner {
        didSet { renderRibbon() }
    }
    
     /// Added padding to ribbon when ribbon is autoresized.
    open var autoresizePadding: CGFloat = 10.0 {
        didSet { renderRibbon() }
    }
    
     /// When true the ribbon will autoresize to wrap it's content.
    open var autoresizes: Bool = false {
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
    public override init(layer: Any) {
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
    
    fileprivate func initializeUI(){
        self.label = RicRibbonLabel()
        label.delegate = self
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
        label.numberOfLines = 0
        
        marginWidth = 1
    }
    
    // MARK: Parent methods
    
    override open func awakeFromNib() {
        initializeUI()
    }
    
    override open func layoutSublayers() {
        super.layoutSublayers()
        renderRibbon()
    }
    
    // MARK: Public methods
    
    /**
     Surrounds an UIView with the current ribbon.
     
     @param view UIView that will be surrounded by the ribbon.
     */
    open func wrap(_ view: UIView) {
        view.layer.insertSublayer(self, at: 0)
        
        maskView = UIView(frame: CGRect(x: -decorationSize, y: -decorationSize, width: view.bounds.width + decorationSize*2, height: view.bounds.height + decorationSize*2))
        maskView.clipsToBounds = true
        view.addSubview(maskView)
        maskView.addSubview(label)
        maskView.isUserInteractionEnabled = false
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
    open func setDashPattern(_ lineWidth: CGFloat, spaceWidth: CGFloat){
        stripeWidth = lineWidth
        stripeSpaceWidth = spaceWidth
    }
    
    // MARK: Render methods
    
    fileprivate func renderRibbon(){
        let path = CGMutablePath()
        
        if let frame = wrappedView?.frame {
            let hDistance = keepInBounds ? distanceForBounds(frame.size.width) : originDistance
            let vDistance = keepInBounds ? distanceForBounds(frame.size.height) : originDistance
            
            let distance =  min(hDistance, vDistance)
            
            calcPoints(distance)
            setTransformForDistance(distance)
            
            if ribbonPoints.count > 0 {
                path.move(to: CGPoint(x: ribbonPoints[0].x, y: ribbonPoints[0].y))
            }
            
            for i in 0 ..< ribbonPoints.count {
                let pos = (i + 1) % ribbonPoints.count
                path.addLine(to: CGPoint(x: ribbonPoints[pos].x, y: ribbonPoints[pos].y))
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
    
    fileprivate func renderDecoration(){
        switch type {
        case .topLeftCorner, .topRightCorner, .bottomLeftCorner, .bottomRightCorner:
            renderCornerDecoration()
        case .left, .right, .top:
            renderEdgeDecoration()
        }
        
    }
    
    fileprivate func renderCornerDecoration() {
        //init
        let decorationOffset:CGFloat = type == .topRightCorner || type == .bottomRightCorner ? -decorationSize : decorationSize
        
        decorationLayer = configShapeLayerIfNeeded(decorationLayer)
        decorationShadowLayer = configShapeLayerIfNeeded(decorationShadowLayer)
        decorationLayer2 = configShapeLayerIfNeeded(decorationLayer2)
        decorationShadowLayer2 = configShapeLayerIfNeeded(decorationShadowLayer2)
        
        //First decoration layer
        var points = [CGPoint(x: ribbonPoints[0].x + decorationOffset, y: -decorationSize),
                      CGPoint(x: ribbonPoints[1].x + decorationOffset, y: -decorationSize),
                      CGPoint(x: ribbonPoints[1].x, y: marginWidth),
                      CGPoint(x: ribbonPoints[0].x, y: marginWidth)]
        
        if type == .bottomRightCorner || type == .bottomLeftCorner {
            points = points.map(flipVertically)
        }
        
        configDecorationLayerUI(decorationLayer, path: pointsToPath(points))
        
        //First shadow layer
        var shadowPoints = [CGPoint(x: ribbonPoints[1].x + decorationOffset, y: -decorationSize),
                            CGPoint(x: ribbonPoints[1].x + decorationOffset - decorationOffset/5, y: marginWidth),
                            CGPoint(x: ribbonPoints[1].x, y: marginWidth)]
        
        if type == .bottomRightCorner || type == .bottomLeftCorner {
            shadowPoints = shadowPoints.map(flipVertically)
        }
        
        configShadowLayerUI(decorationShadowLayer, path: pointsToPath(shadowPoints))
        
        var vDecorationOffset = decorationOffset
        if type == .bottomLeftCorner || type == .topRightCorner {
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
    
    fileprivate func renderEdgeDecoration() {
        if type == .right || type == .left{
            
            let offset = type == .right ? decorationSize : -decorationSize
            let margin = type == .right ? -marginWidth/2 : marginWidth/2
            
            decorationLayer = configShapeLayerIfNeeded(decorationLayer)
            decorationShadowLayer = configShapeLayerIfNeeded(decorationShadowLayer)
            
            let points = [CGPoint(x: ribbonPoints[0].x + margin, y: ribbonPoints[0].y),
                          CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[0].y),
                          CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[1].y),
                          CGPoint(x: ribbonPoints[0].x + margin, y: ribbonPoints[1].y)]
            
            configDecorationLayerUI(decorationLayer, path: pointsToPath(points))
            
            //shadow
            let shadowPoints = [CGPoint(x: ribbonPoints[0].x + offset, y: ribbonPoints[0].y),
                                CGPoint(x: ribbonPoints[0].x + margin, y: ribbonPoints[0].y - abs(offset*3/5)),
                                CGPoint(x: ribbonPoints[0].x + margin, y: ribbonPoints[0].y)]
            
            configShadowLayerUI(decorationShadowLayer, path: pointsToPath(shadowPoints))
        } else if type == .top{
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
    
    fileprivate func calcPoints(_ distance: CGFloat) {
        ribbonPoints.removeAll()
        
        if let frame = wrappedView?.frame{
            switch self.type {
            case .topLeftCorner, .topRightCorner, .bottomLeftCorner, .bottomRightCorner:
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
            case .left, .right, .top:
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2))
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2 + ribbonWidth))
                ribbonPoints.append(CGPoint(x: ribbonLength + marginWidth/2, y: distance + marginWidth/2 + ribbonWidth))
                ribbonPoints.append(CGPoint(x: ribbonLength + marginWidth/2, y: distance + marginWidth/2))
                ribbonPoints.append(CGPoint(x: marginWidth/2, y: distance + marginWidth/2))
            }
            ribbonPoints = ribbonPoints.map({ (point: CGPoint) -> CGPoint in
                switch self.type {
                case .topRightCorner, .right:
                    return CGPoint(x: frame.width - point.x, y: point.y)
                case .bottomLeftCorner:
                    return CGPoint(x: point.x, y: frame.height - point.y)
                case .bottomRightCorner:
                    return CGPoint(x: frame.width - point.x, y: frame.height - point.y)
                case .top:
                    return CGPoint(x: point.y, y: point.x)
                default:
                    return CGPoint(x: point.x, y: point.y)
                }
            })
        }
    }
    
    // MARK: UI methods
    
    fileprivate func applyMasks(){
        let maskPath = CGMutablePath()
        
        maskPath.move(to: CGPoint(x: 0, y: wrappedView.frame.height))
        maskPath.addLine(to: CGPoint(x: wrappedView.frame.width, y: wrappedView.frame.height))
        maskPath.addLine(to: CGPoint(x: wrappedView.frame.width, y: 0))
        maskPath.addLine(to: CGPoint(x: 0, y: 0))
        maskPath.addLine(to: CGPoint(x: 0, y: wrappedView.frame.height))
        
        /*CGPathMoveToPoint(maskPath, nil, 0, wrappedView.frame.height)
        CGPathAddLineToPoint(maskPath, nil, wrappedView.frame.width, wrappedView.frame.height)
        CGPathAddLineToPoint(maskPath, nil, wrappedView.frame.width, 0)
        CGPathAddLineToPoint(maskPath, nil, 0, 0)
        CGPathAddLineToPoint(maskPath, nil, 0, wrappedView.frame.height)*/
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        maskLayer.strokeColor = UIColor.red.cgColor
        
        self.mask = maskLayer
    }
    
    fileprivate func setSizeToFit() {
        label.sizeToFit()
        label.setNeedsLayout()
        label.setNeedsDisplay()
        label.layoutIfNeeded()
    }
    
    fileprivate func configureShape(with path: CGMutablePath) {
        self.path = path
        self.fillColor = ribbonColor
        self.lineWidth = marginWidth
        self.strokeColor = marginColor
        self.lineDashPattern = [stripeWidth as NSNumber, stripeSpaceWidth as NSNumber]
        
        if usesShadow {
            self.shadowOffset = CGSize(width: 0, height: 10)
            self.shadowRadius = 10.0
            self.shadowColor = UIColor.black.cgColor
            self.shadowOpacity = 0.5
        } else {
            self.shadowOpacity = 0.0
        }
    }
    
    fileprivate func setTransformForDistance(_ distance: CGFloat) {
        label.transform = CGAffineTransform.identity
        self.label.frame = CGRect(x: offset, y: distance, width: getLargeDistance(), height: ribbonWidth)
        
        let elements = CGFloat(ribbonPoints.count - 1)
        
        if ribbonPoints.count > 0 {
            let x = ribbonPoints.suffix(from: 1).reduce(0) { $0 + ($1.x / elements) }
            let y = ribbonPoints.suffix(from: 1).reduce(0) { $0 + ($1.y / elements) }
            label.center = CGPoint(x: x + decorationSize, y: y + decorationSize)
        }
        
        switch self.type {
        case .topLeftCorner, .bottomRightCorner:
            angle = CGFloat(-M_PI/4)
            break
        case .topRightCorner, .bottomLeftCorner:
            angle = CGFloat(M_PI/4)
            break
        case .top:
            angle = CGFloat(M_PI/2)
            break
        default:
            break
        }
        
        label.transform = label.transform.rotated(by: angle)
    }
    
    // MARK: Util methods
    
    fileprivate func configShadowLayerUI(_ layer: CAShapeLayer, path: CGMutablePath) {
        layer.path = path
        layer.fillColor = UIColor.darkGray.cgColor
    }
    
    fileprivate func configDecorationLayerUI(_ layer: CAShapeLayer, path: CGMutablePath) {
        layer.path = path
        layer.fillColor = ribbonColor
        layer.lineWidth = marginWidth
    }
    
    fileprivate func configShapeLayerIfNeeded(_ shapeLayer: CAShapeLayer?) -> CAShapeLayer{
        if let layer = shapeLayer {
            return layer
        } else {
            let layer = CAShapeLayer()
            wrappedView.layer.insertSublayer(layer, at: 0)
            return layer
        }
    }
    
    fileprivate func pointsToPath(_ points: Array<CGPoint>) -> CGMutablePath{
        let path = CGMutablePath()
        
        if points.count > 0 {
            path.move(to: CGPoint(x: points[0].x, y: points[0].y))
        }
        
        for i in 0 ..< points.count {
            let pos = (i + 1) % points.count
            path.addLine(to: CGPoint(x: points[pos].x, y: points[pos].y))
        }
        return path
    }
    
    fileprivate func flipVertically(_ point: CGPoint) -> CGPoint{
        return CGPoint(x: point.x, y: wrappedView.frame.height - point.y)
    }
    
    // MARK: Distance calc methods
    
    fileprivate func getLargeDistance() -> CGFloat{
        if ribbonPoints.count > 2{
            let xDist = (ribbonPoints[2].x - ribbonPoints[1].x);
            let yDist = (ribbonPoints[2].y - ribbonPoints[1].y);
            return sqrt((xDist * xDist) + (yDist * yDist));
        }
        return 0
    }
    
    fileprivate func getShortDistance() -> CGFloat{
        if ribbonPoints.count > 2{
            let xDist = (ribbonPoints[0].x - ribbonPoints[ribbonPoints.count - 2].x);
            let yDist = (ribbonPoints[0].y - ribbonPoints[ribbonPoints.count - 2].y);
            return sqrt((xDist * xDist) + (yDist * yDist));
        }
        return 0
    }
    
    fileprivate func distanceForBounds(_ parentSize: CGFloat) -> CGFloat {
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
    open func ribbonLabelUpdatedLayout(_ sender: RicRibbonLabel) {
        if autoresizes {
            switch self.type {
            case .topLeftCorner, .bottomRightCorner, .topRightCorner, .bottomLeftCorner, .left, .right:
                ribbonWidth = sender.bounds.height + autoresizePadding
                break
            case .top:
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
    case topLeftCorner
    case topRightCorner
    case bottomLeftCorner
    case bottomRightCorner
    case left
    case right
    case top
}
