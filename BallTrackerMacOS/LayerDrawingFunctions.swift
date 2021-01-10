//
// TennisBallTracker (BallTrackerMacOS)
// File created by Adrian Baumgart on 06.01.20.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://github.com/leabmgrt/TennisBallTracker
//

import Cocoa
import Vision

func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
    let textLayer = CATextLayer()
    textLayer.name = "Object Label"
    textLayer.string = String(format: "\(identifier)\nConfidence:  %.2f", confidence)
    textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
    textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    textLayer.shadowOpacity = 0.7
    textLayer.shadowOffset = CGSize(width: 2, height: 2)
    textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
    textLayer.contentsScale = 2.0
    textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
    return textLayer
}

func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
    let shapeLayer = CALayer()
    let newbounds = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height)
    shapeLayer.frame = newbounds
    shapeLayer.name = "foundRect"
    shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
    shapeLayer.cornerRadius = 7
    return shapeLayer
}

func createDotLayerWithBounds(_ bounds: CGRect, color: NSColor = NSColor.red, name: String, followWidthHeight: Bool) -> CALayer {
    let layer = CALayer()
    layer.frame = calcRedDotValues(bounds, addWidthSubtraction: true, followWidthHeight: followWidthHeight)
    layer.name = name
    layer.backgroundColor = color.cgColor
    layer.cornerRadius = CGFloat((followWidthHeight ? bounds.width : 20 / 2))
    return layer
}

func createBoxBorderAroundDot(_ bounds: CGRect) -> CALayer {
    let layer = CALayer()
    layer.frame = bounds
    layer.name = "boxAroundDot"
    layer.borderWidth = CGFloat(1.5)
    layer.borderColor = NSColor.red.cgColor
    return layer
}

func calcRedDotValues(_ bounds: CGRect, addWidthSubtraction: Bool, followWidthHeight: Bool) -> CGRect {
    let width = followWidthHeight ? bounds.width : CGFloat(20)
    let height = followWidthHeight ? bounds.height : CGFloat(20)
    let xValue = bounds.minX + (bounds.width / 2) - (addWidthSubtraction ? (width / 2) : 0)
    let yValue = bounds.minY + (bounds.height / 2) - (addWidthSubtraction ? (height / 2) : 0)
    return CGRect(x: xValue, y: yValue, width: width, height: height)
}
