//
//  ProgressTrack.swift
//  ProgressTrack
//
//  Created by yalight on 2015/10/22.
//  Copyright © 2015年 Yalight. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol ProgressTrackDelegate {
    func progressTrackBarTappedUp(progressTrack: ProgressTrack, fromProgressValue: Float, toProgressValue: Float)
}

@IBDesignable
class ProgressTrack: UIControl {

    enum ColorStyle : String {
        case RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE
    }
    
    weak var delegate: ProgressTrackDelegate?
    
    /* Set default data for renderring in Interface Builder */
    var trackData: [Float] = [0.2, 0.3, 0.8, 0.7, 0.6, 0.7, 0.8, 0.9, 1.0, 0.8, 0.4, 0.1] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var minimumValue: Float = 0 {
        didSet {
            if minimumValue > maximumValue {
                minimumValue = oldValue
            }
            
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var maximumValue: Float = 1 {
        didSet {
            if maximumValue < minimumValue {
                maximumValue = oldValue
            }
            
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var gapWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var barWidth: CGFloat {
        get {
            return (self.bounds.width - gapWidth * CGFloat(trackData.count - 1)) / CGFloat(trackData.count)
        }
    }

    var previousProgressValue: Float = 0
    
    @IBInspectable
    var progressValue: Float = 0 {
        
        didSet {
            if progressValue > 1 {
                progressValue = 1
            } else if progressValue < 0 {
                progressValue = 0
            }
            
            setNeedsDisplay()
        }
    }
    
    var currentBarIndex: Int {
        get {
            if trackData.count > 0 {
                return getBarIndexByProgressValue(progressValue)
            } else {
                return -1
            }
        }
        
        set {
            if newValue >= 0 && newValue < trackData.count {
                self.progressValue = Float(newValue) / Float(trackData.count)
            }
        }
    }
    
    var barValue: Float? {
        get {
            let barIndex = currentBarIndex
            
            if barIndex >= 0 {
                return trackData[barIndex]
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable
    var barHeightRatio: CGFloat = 0.75 {
        didSet {
            if barHeightRatio > 1 {
                barHeightRatio = 1
            } else if barHeightRatio < 0 {
                barHeightRatio = 0
            }
            
            setNeedsDisplay()
        }
    }
    
    var tappedPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    static let barGradientColors = [ColorStyle.RED.rawValue:
                             (UIColor(red: 0.8118, green: 0.0157, blue: 0.0157, alpha: 0),
                              UIColor(red: 1.0, green: 0.1882, blue: 0.098, alpha: 0)),
                             ColorStyle.ORANGE.rawValue:
                             (UIColor(red: 1.0, green: 0.182, blue: 0, alpha: 0),
                              UIColor(red: 1.0, green: 0.451, blue: 0, alpha: 0)),
                             ColorStyle.YELLOW.rawValue:
                             (UIColor(red: 0.9725, green: 0.7098, blue: 0, alpha: 1.0),
                              UIColor(red: 0.9843, green: 0.8745, blue: 0.5765, alpha: 1.0)),
                             ColorStyle.GREEN.rawValue:
                             (UIColor(red: 0.4392, green: 0.6471, blue: 0.3686, alpha: 0),
                              UIColor(red: 0.6627, green: 0.8588, blue: 0.5021, alpha: 0)),
                             ColorStyle.BLUE.rawValue:
                             (UIColor(red: 0.1255, green: 0.349, blue: 0.6274, alpha: 0),
                              UIColor(red: 0.1607, green: 0.5372, blue: 0.847, alpha: 0)),
                             ColorStyle.PURPLE.rawValue:
                             (UIColor(red: 0.6784, green: 0.0706, blue: 0.5137, alpha: 0),
                              UIColor(red: 0.7961, green: 0.3647, blue: 0.7019, alpha: 0)),
                            ]
    
    static let barShadowColors = [ColorStyle.RED.rawValue: UIColor(red: 1.0, green: 0.6196, blue: 0.6196, alpha: 1.0),
                           ColorStyle.ORANGE.rawValue: UIColor(red: 1.0, green: 0.6, blue: 0.41176, alpha: 1.0),
                           ColorStyle.YELLOW.rawValue: UIColor(red: 0.9686, green: 0.8706, blue: 0.6275, alpha: 1.0),
                           ColorStyle.GREEN.rawValue: UIColor(red: 0.7373, green: 0.8078, blue: 0.2078, alpha: 1.0),
                           ColorStyle.BLUE.rawValue: UIColor(red: 0.1607, green: 0.5372, blue: 0.847, alpha: 1.0),
                           ColorStyle.PURPLE.rawValue: UIColor(red: 0.8275, green: 0.6706, blue: 0.8, alpha: 1.0),];
    
    static let barSelectedColors = [ColorStyle.RED.rawValue: UIColor(red: 0.6274, green: 0.1608, blue: 0.1412, alpha: 1.0),
                             ColorStyle.ORANGE.rawValue: UIColor(red: 0.643, green: 0.251, blue: 0.137, alpha: 1.0),
                             ColorStyle.YELLOW.rawValue: UIColor(red: 0.9686, green: 0.7216, blue: 0.1059, alpha: 1.0),
                             ColorStyle.GREEN.rawValue: UIColor(red: 0.4920, green: 0.6078, blue: 0.3333, alpha: 1.0),
                             ColorStyle.BLUE.rawValue: UIColor(red:0.357, green:0.749, blue:0.863, alpha:1.0),
                             ColorStyle.PURPLE.rawValue: UIColor(red:0.7686, green:0.098, blue:0.4431, alpha:1.0),]
    
    var barGradientColor: (UIColor, UIColor) = ProgressTrack.barGradientColors[ColorStyle.ORANGE.rawValue]! {
        didSet {
            barImage = createTrackBarImage(CGSize(width: barWidth, height: bounds.size.height), gradientColors: barGradientColor)
        }
    }
    
    var barShadowColor: UIColor = ProgressTrack.barShadowColors[ColorStyle.ORANGE.rawValue]! {
        didSet {
            barImage = createTrackBarImage(CGSize(width: barWidth, height: bounds.size.height), gradientColors: barGradientColor)
        }
    }
    
    var barSelectedColor: UIColor = ProgressTrack.barSelectedColors[ColorStyle.ORANGE.rawValue]! {
        didSet {
            barImage = createTrackBarImage(CGSize(width: barWidth, height: bounds.size.height), gradientColors: barGradientColor)
        }
    }
    
    var colorStyle: ColorStyle = ColorStyle.ORANGE {
        didSet {
            barGradientColor = ProgressTrack.barGradientColors[colorStyle.rawValue]!
            barShadowColor = ProgressTrack.barShadowColors[colorStyle.rawValue]!
            barSelectedColor = ProgressTrack.barSelectedColors[colorStyle.rawValue]!
            
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var barImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }
    
    func initProperties() {
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        if trackData.count <= 0 {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let barMaxHeight = bounds.size.height * barHeightRatio
        
        var trackBarRects: [CGRect] = []
        var shadowTrackBarRects: [CGRect] = []
        var x: CGFloat = 0.0
        
        for value in trackData {
            
            let h = CGFloat( (value - minimumValue) / (maximumValue - minimumValue) ) * barMaxHeight
            let y = barMaxHeight - h
            let trackBarRect = CGRect(x: x, y: y, width: barWidth, height: h)
            trackBarRects.append(trackBarRect)
            
            let sh = CGFloat( (value - minimumValue) / (maximumValue - minimumValue) ) * bounds.size.height * (1 - barHeightRatio) - 0.5
            let sy = barMaxHeight + 0.5
            let shadowTrackBarRect = CGRect(x: x, y: sy, width: barWidth, height: sh)
            shadowTrackBarRects.append(shadowTrackBarRect)
            
            x += barWidth + gapWidth
        }

        /* Create track bar gradient image */
        
        if barImage == nil {
            barImage = createTrackBarImage(CGSize(width: barWidth, height: bounds.size.height), gradientColors: barGradientColor)
        }
        
        /* Draw track bar */
        
        let currentIndex = currentBarIndex
        
        var tappedIndex: Int?
        
        if let tp = tappedPoint {
            tappedIndex = max(min(Int(tp.x / (barWidth + gapWidth)), trackData.count - 1), 0)
        }
        
        if let image = barImage {
            
            var drawBarIndex = currentIndex
            
            // Set the drawing index to the tapped index if user taps on it
            if let ti = tappedIndex {
                if ti < currentIndex {
                    drawBarIndex = ti
                }
            }
            
            for i in 0..<drawBarIndex {
                CGContextDrawImage(ctx, trackBarRects[i], image.CGImage)
            }
            
            if progressValue >= 1.0 {
                CGContextDrawImage(ctx, trackBarRects[trackData.count-1], image.CGImage)
            }
        } else {
            fatalError("Bar image is nil.")
        }
        
        // Fade in current bar
        let barAlpha = 0.1 + (progressValue * Float(trackData.count) - Float(currentIndex)) * 0.9
        
        if progressValue < 1.0 {
            
            var drawBarIndex = currentIndex
            
            // Set the drawing index to the tapped index if user taps on it
            if let ti = tappedIndex {
                if ti > currentIndex {
                    drawBarIndex = ti
                }
            }
            
            let grayBars = Array(trackBarRects[drawBarIndex..<trackBarRects.count])
            UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0).setFill()
            CGContextAddRects(ctx, grayBars, grayBars.count)
            CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
        
            let fadeColor = getColorByModifyAlpha(barGradientColor.0, newAlpha: CGFloat(barAlpha))
            fadeColor.setFill()
            CGContextAddRect(ctx, trackBarRects[currentIndex])
            CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
        }
        
        /* Draw shadow bar */
        if currentIndex > 0 {
            barShadowColor.setFill()
            
            if progressValue < 1.0 {
                CGContextAddRects(ctx, shadowTrackBarRects, currentIndex)
            } else {
                CGContextAddRects(ctx, shadowTrackBarRects, trackData.count)
            }
            
            CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
        }
        
        if progressValue < 1.0 {
            let shadowGrayBars = Array<CGRect>(shadowTrackBarRects[currentIndex..<shadowTrackBarRects.count])
            UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).setFill()
            CGContextAddRects(ctx, shadowGrayBars, shadowGrayBars.count)
            CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
        
            // Fade in current shadow bar
            getColorByModifyAlpha(barShadowColor, newAlpha: CGFloat(barAlpha)).setFill()
            CGContextAddRect(ctx, shadowTrackBarRects[currentIndex])
            CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
        }
        
        // Draw bars of tapped section
        if let ti = tappedIndex {
            
            let currentX = CGFloat(progressValue) * bounds.size.width
            
            barSelectedColor.setFill()
            
            if tappedPoint!.x <= currentX {
                CGContextAddRects(ctx, Array(trackBarRects[ti...currentIndex]), currentIndex - ti + 1)
                CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
                
            } else {
                if tappedIndex > currentIndex {
                    CGContextAddRects(ctx, Array(trackBarRects[currentIndex+1...ti]), ti - currentIndex)
                    CGContextDrawPath(ctx, CGPathDrawingMode.Fill)
                }
            }
        }
    }
    
    func getBarIndexByProgressValue(progressValue: Float) -> Int {
        var barIndex = Int(Float(trackData.count) * progressValue)
        barIndex = max(min(barIndex, trackData.count - 1), 0)
        return barIndex
    }
    
    func getColorByModifyAlpha(color: UIColor, newAlpha: CGFloat) -> UIColor {
        let rgba = CGColorGetComponents(color.CGColor)
        let newColor = UIColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: newAlpha)
        return newColor
    }
    
    func createTrackBarImage(size: CGSize, gradientColors: (startColor: UIColor, endColor: UIColor)) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        
        let imageCtx: CGContext? = UIGraphicsGetCurrentContext()
        
        if imageCtx == nil {
            return nil
        }
        
        let startColor = gradientColors.startColor
        let endColor = gradientColors.endColor
        
        // Split colors in components (rgba)
        let startColorComps:UnsafePointer<CGFloat> = CGColorGetComponents(startColor.CGColor);
        let endColorComps:UnsafePointer<CGFloat> = CGColorGetComponents(endColor.CGColor);
        
        let components : [CGFloat] = [
            startColorComps[0], startColorComps[1], startColorComps[2], 1.0,     // Start color
            endColorComps[0], endColorComps[1], endColorComps[2], 1.0      // End color
        ]
        
        // Setup the gradient
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(baseSpace, components, nil, 2)
        
        // Gradient direction
        let startPoint = CGPointMake(0, 0)
        let endPoint = CGPointMake(0, size.height)
        CGContextDrawLinearGradient(imageCtx, gradient, startPoint, endPoint, [])
        
        let trackBarImage: CGImageRef? = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())
        UIGraphicsEndImageContext()
        
        return UIImage(CGImage: trackBarImage!)
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let lastPoint = touch.locationInView(self)
        tappedPoint = lastPoint
        previousProgressValue = progressValue
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let lastPoint = touch.locationInView(self)
        tappedPoint = lastPoint
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        tappedPoint = nil
        
        if let t = touch {
            let lastPoint = t.locationInView(self)
            let tappedProgressValue = Float(lastPoint.x / (barWidth + gapWidth) / CGFloat(trackData.count))
            progressValue = max(min(tappedProgressValue, 1), 0)
        }
        
        delegate?.progressTrackBarTappedUp(self, fromProgressValue:previousProgressValue , toProgressValue:progressValue)
    }
}
