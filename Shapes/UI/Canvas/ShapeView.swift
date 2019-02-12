import UIKit


/// UI representation of a single shape.

class ShapeView: UIView {

    var highlight: Highlight = .default { didSet { update() }}

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
    }

    func update(from shape: Shape) {
        var position = shape.origin

        if let superview = self.superview {
            position += superview.bounds.mid
        }

        center = position
        shapeLayer.path = shape.path
    }
}


fileprivate extension ShapeView {

    func update() {
        switch highlight {
        case .default:
            shapeLayer.lineWidth = 1
            shapeLayer.strokeColor = UIColor(white: 0, alpha: 0.3).cgColor
        case .selected:
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1).cgColor
        }
    }

    var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    func setup() {
        shapeLayer.fillColor = nil
        update()
    }
}
