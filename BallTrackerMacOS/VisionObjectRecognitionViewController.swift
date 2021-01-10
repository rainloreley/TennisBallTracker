//
// TennisBallTracker (BallTrackerMacOS)
// File created by Adrian Baumgart on 31.12.20.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://github.com/leabmgrt/TennisBallTracker
//

import Cocoa
import AVFoundation
import Vision

class VisionObjectRecognitionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    private var gridOverlay: CALayer! = nil
    
    private var requests = [VNRequest]()
    
    var measurementActive: Bool = false
    
    var measurementValues = [BallTrackValue]()
    
    @IBOutlet weak var enableMLTrackingSwitch: NSSwitch!
    @IBOutlet weak var startMeasurementButton: NSButton!
    @IBOutlet weak var resetValuesButton: NSButton!
    @IBOutlet weak var valueCountLabel: NSTextField!
    @IBOutlet weak var showGridSwitch: NSSwitch!
    @IBOutlet weak var gridDensityPicker: NSComboBox!
    @IBOutlet weak var function1Label: NSTextField!
    @IBOutlet weak var function2Label: NSTextField!
    @IBOutlet weak var measurementStartDelay: NSTextField!
    
    @IBAction func gridDensityChanged(_ sender: NSComboBox) {
        if let selecedInt = sender.objectValueOfSelectedItem {
            buildGrid(Int("\(selecedInt)") ?? 50)
        }
        else {
            sender.selectItem(at: 2)
        }
    }

    @IBAction func toggleGridVisibility(_ sender: NSSwitch) {
        switch sender.state {
        case .on:
            gridOverlay.isHidden = false
        case .off:
            gridOverlay.isHidden = true
        default: break
        }
    }
    
    
    @IBAction func toggleMLTracking(_ sender: NSSwitch) {
        changeCountLabel()
        updateFunctionLabels(vertex: nil, function: nil)
        switch sender.state {
        case .on:
            startMeasurementButton.isEnabled = true
            resetValuesButton.isEnabled = true
            break
        case .off:
            startMeasurementButton.isEnabled = false
            resetValuesButton.isEnabled = false
            break
        default: break
        }
    }
    
    @IBAction func startMeasurement(_ sender: NSButton) {
        if let delay = Int(measurementStartDelay.stringValue), measurementActive == false {
            startMeasurementButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                self.startMeasurementFunc()
            }
        }
        else {
            startMeasurementFunc()
        }
    }
    
    func startMeasurementFunc() {
        measurementActive = !measurementActive
        startMeasurementButton.title = "\(measurementActive ? "Stop" : "Start") Measurement"
        
        startMeasurementButton.isEnabled = true
        resetValuesButton.isEnabled = !measurementActive
        changeCountLabel()
        if measurementActive {
            calcParabola(false)
        }
    }
    
    @IBAction func resetValues(_ sender: Any) {
        measurementValues = []
        changeCountLabel()
        updateFunctionLabels(vertex: nil, function: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch enableMLTrackingSwitch.state {
        case .on:
            startMeasurementButton.isEnabled = true
            resetValuesButton.isEnabled = true
            break
        case .off:
            startMeasurementButton.isEnabled = false
            resetValuesButton.isEnabled = false
            break
        default: break
        }
        
        switch showGridSwitch.state {
            case .on:
                gridOverlay.isHidden = false
            case .off:
                gridOverlay.isHidden = true
            default: break
        }
        gridDensityPicker.selectItem(at: 2)
        startMeasurementButton.title = "\(measurementActive ? "Stop" : "Start") Measurement"
        changeCountLabel()
        updateFunctionLabels(vertex: nil, function: nil)
    }
    
    func changeCountLabel() {
        valueCountLabel.stringValue = "Value Count: \(measurementValues.count)"
    }
    
    func roundDoubleToXPlaces(_ double: Double, places: Int) -> String {
        return String(format: "%.\(places)f", double)
        
    }
    
    func updateFunctionLabels(vertex: Parabola_Vertex?, function: Parabola_Function?) {
        if vertex != nil {
            function1Label.stringValue = "\(roundDoubleToXPlaces(vertex!.a, places: 2))x² + \(roundDoubleToXPlaces(vertex!.b, places: 2))x + \(roundDoubleToXPlaces(vertex!.c, places: 2))"
        }
        else {
            function1Label.stringValue = "Function 1:"
        }
        if function != nil {
            function2Label.stringValue = "\(roundDoubleToXPlaces(function!.a, places: 2)) * (x - \(roundDoubleToXPlaces(function!.d, places: 2)))² + \(roundDoubleToXPlaces(function!.e, places: 2))"
        }
        else {
            function2Label.stringValue = "Function 2:"
        }
    }
    
    func buildGrid(_ density: Int = 50) {
        if gridOverlay == nil {
            gridOverlay = CALayer()
            gridOverlay.name = "GridOverlay"
            gridOverlay.bounds = CGRect(x: 0.0,
                                             y: 0.0,
                                             width: bufferSize.width,
                                             height: bufferSize.height)
            gridOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
            rootLayer.addSublayer(gridOverlay)
        }
        else {
            gridOverlay.sublayers = nil
        }
        
        let linethickness = 0.5
        for i in 0...Int(bufferSize.width) {
            if i % density == 0 {
                gridOverlay.addSublayer(buildLine(.init(x: CGFloat(i), y: 0, width: CGFloat(linethickness), height: bufferSize.height)))
                gridOverlay.addSublayer(buildLineDescription(.init(x: CGFloat(i + 10), y: 10, width: 20, height: 20), text: "\(i)"))
            }
        }
        for i in 0...Int(bufferSize.height) {
            if i % density == 0 {
                gridOverlay.addSublayer(buildLine(.init(x: 0, y: CGFloat(i), width: bufferSize.width, height: CGFloat(linethickness))))
                gridOverlay.addSublayer(buildLineDescription(.init(x: 10, y: CGFloat(i + 10), width: 20, height: 20), text: "\(i)"))
            }
        }
    }
    
    func buildLine(_ at: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: at.minX, y: at.minY, width: at.width, height: at.height)
        layer.backgroundColor = NSColor.red.cgColor
        return layer
    }
    
    func buildLineDescription(_ at: CGRect, text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.name = text
        textLayer.foregroundColor = NSColor.red.cgColor
        textLayer.fontSize = CGFloat(10)
        textLayer.frame = at

        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(45)))
        textLayer.contentsScale = 2.0
        return textLayer
    }
    
    @discardableResult
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        
        guard let modelURL = Bundle.main.url(forResource: "TennisBallDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    guard let results = request.results else { return }
                    if self.enableMLTrackingSwitch.state == .on {
                    self.detectionOverlay.isHidden = false
                    self.drawVisionRequestResults(results)
                }
                else if self.enableMLTrackingSwitch.state == .off {
                    self.detectionOverlay.isHidden = true
                }
                else if self.measurementActive {
                    self.calcParabola(true)
                }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        changeCountLabel()
        CATransaction.begin()
        previewLayer.frame = rootLayer.bounds
        detectionOverlay.bounds = rootLayer.bounds
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if measurementActive || measurementValues.count > 0 {
            detectionOverlay.sublayers?.removeAll(where: {$0.name == "foundRect"})
        }
        else {
            detectionOverlay.sublayers = nil
        }
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = measurementActive ? createDotLayerWithBounds(objectBounds, name: "foundDot", followWidthHeight: false) : createRoundedRectLayerWithBounds(objectBounds)
            
            if measurementActive {
                let timestamp = Date().timeIntervalSince1970 * 1000
                let redDot = calcRedDotValues(objectBounds, addWidthSubtraction: false, followWidthHeight: false)
                let newValue = BallTrackValue(x: Double(redDot.minX), y: Double(redDot.minY), timestamp: Int(timestamp))
                measurementValues.append(newValue)
                changeCountLabel()
                calcParabola(true)
            }
            detectionOverlay.addSublayer(shapeLayer)
            
            if measurementActive {
                let boxAroundDotLayer = createBoxBorderAroundDot(objectBounds)
                detectionOverlay.addSublayer(boxAroundDotLayer)
            }
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = CGImagePropertyOrientation.up
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        setupLayers()
        updateLayerGeometry()
        setupVision()
        startCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
        
        buildGrid()
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func drawRect() {
        
        let shapeLayer = createRoundedRectLayerWithBounds(CGRect(x: 0, y: 0, width: 200, height: 200))
        detectionOverlay.addSublayer(shapeLayer)
        
    }
}


struct BallTrackValue {
    var x: Double
    var y: Double
    var timestamp: Int
}

struct Parabola_Value {
    var x: Double
    var y: Double
}

extension VisionObjectRecognitionViewController {
    func calcParabola(_ allowsMeasurement: Bool) {
        if measurementActive == allowsMeasurement, measurementValues.count >= 3 {
            
            detectionOverlay.sublayers?.removeAll(where: { $0.name == "finalParabola" || $0.name == "zeroCrossings" })
            
            guard let highestYp1 = measurementValues.max(by: {$0.y < $1.y}) else { return }
            guard let p2Left = measurementValues.filter({ $0.x < highestYp1.x}).randomElement() else { return }
            guard let p3Right = measurementValues.filter({ $0.x > highestYp1.x}).randomElement() else { return }
            
            let vertex = calculate_parabola_vertex(x1: highestYp1.x, y1: highestYp1.y, x2: p2Left.x, y2: p2Left.y, x3: p3Right.x, y3: p3Right.y)
            let function = calculate_parabola_function(a: vertex.a, b: vertex.b, c: vertex.c)
            let zeroCrossings = calculate_parabola_zero_crossings(vertex: vertex)
            
            updateFunctionLabels(vertex: vertex, function: function)
            
            for x in 0...Int(bufferSize.width) {
                let y = (Double(vertex.a) * (Double(x) * Double(x)) + vertex.b * Double(x) + vertex.c)
                
                let dot = createDotLayerWithBounds(CGRect(x: Double(x), y: y, width: 10, height: 10), color: NSColor.green, name: "finalParabola", followWidthHeight: true)
                
                detectionOverlay.addSublayer(dot)
            }
            
            for x in zeroCrossings {
                let dot = createDotLayerWithBounds(CGRect(x: x, y: 0, width: 20, height: 20), color: NSColor.yellow, name: "zeroCrossings", followWidthHeight: true)
                detectionOverlay.addSublayer(dot)
            }
            
        }
    }
}
