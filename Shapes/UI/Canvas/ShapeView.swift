import UIKit


/// UI representation of a single shape.

class ShapeView: UIView {

    var highlight: Highlight = .default { didSet { update() }}
    fileprivate var controlLayers: [CALayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
}


extension ShapeView {

    enum Highlight {
        case `default`
        case selected
        case editing(elementIndex: Int)
    }

    var path: CGPath? {
        get { return shapeLayer.path }
        set {
            shapeLayer.path = newValue
            update()
        }
    }
}


fileprivate extension ShapeView {

    func update() {
        switch highlight {
        case .default:
            shapeLayer.lineWidth = 1
            shapeLayer.strokeColor = UIColor(white: 0, alpha: 0.3).cgColor
            controlLayers.forEach { $0.removeFromSuperlayer() }
            controlLayers = []
            return

        case .selected:
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1).cgColor
            updateControlLayers(highlightedElementIndex: nil)

        case .editing(let elementIndex):
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1).cgColor
            updateControlLayers(highlightedElementIndex: elementIndex)
        }
    }

    func updateControlLayers(highlightedElementIndex: Int?) {
        controlLayers.forEach { $0.removeFromSuperlayer() }
        controlLayers = []

        var currentIndex = 0
        var previousPoint = CGPoint.zero

        shapeLayer.path?.applyWithBlock {
            pathElementPtr in

            defer { currentIndex += 1 }

            switch pathElementPtr.pointee.type {
            case .moveToPoint, .addLineToPoint:
                addControlLayer(at: pathElementPtr.pointee.points.pointee, isHighlighted: currentIndex == highlightedElementIndex)
                previousPoint = pathElementPtr.pointee.points.pointee

            case .addCurveToPoint:
                addControlLayer(at: pathElementPtr.pointee.points[2], isHighlighted: currentIndex == highlightedElementIndex)

                if currentIndex == highlightedElementIndex {
                    addBezierControl(from: pathElementPtr.pointee.points[1], to: pathElementPtr.pointee.points[2])
                    addControlLayer(at: pathElementPtr.pointee.points[1], isBezierControl: true)
                } else if currentIndex - 1 == highlightedElementIndex {
                    addBezierControl(from: pathElementPtr.pointee.points[0], to: previousPoint)
                    addControlLayer(at: pathElementPtr.pointee.points[0], isBezierControl: true)
                }
                previousPoint = pathElementPtr.pointee.points[2]

            case .closeSubpath:
                break

            case .addQuadCurveToPoint:
                preconditionFailure("we do not support quad curves")
            }
        }
    }

    func addBezierControl(from startPoint: CGPoint, to endPoint: CGPoint) {
        let lineLayer = CALayer()
        lineLayer.backgroundColor = UIColor.red.cgColor
        lineLayer.bounds = CGRect(origin: .zero, size: CGSize(width: (startPoint - endPoint).length, height: 1))
        lineLayer.position = (startPoint + endPoint) * 0.5
        lineLayer.setAffineTransform(CGAffineTransform(rotationAngle: (startPoint - endPoint).angle))

        shapeLayer.addSublayer(lineLayer)
        controlLayers.append(lineLayer)
    }

    func addControlLayer(at position: CGPoint, isBezierControl: Bool = false, isHighlighted: Bool = false) {
        let layer = CALayer()

        var size = CGSize(width: 10, height: 10)
        if isHighlighted {
            layer.backgroundColor = UIColor.blue.cgColor
        } else if isBezierControl {
            layer.backgroundColor = UIColor.red.cgColor
            layer.cornerRadius = 3.5
            size = CGSize(width: 7, height: 7)
        } else {
            layer.borderColor = UIColor.blue.cgColor
            layer.borderWidth = 1
        }
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.position = position
        shapeLayer.addSublayer(layer)
        controlLayers.append(layer)
    }

    var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    func setup() {
        shapeLayer.fillColor = nil
        update()
    }
}
