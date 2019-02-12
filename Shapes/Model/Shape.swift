import Foundation
import CoreGraphics


public struct Shape {
    var name: String
    var origin: CGPoint
    var path: CGPath
}


public extension Shape {
    func contains(_ point: CGPoint) -> Bool {
        return path.contains(point - origin,
                             using: .winding,
                             transform: .identity)
    }

    var boundingBox: CGRect {
        return path.boundingBoxOfPath
    }
}

// MARK: - Some template shape values
public extension Shape {

    static var rectangle: Shape {
        let path = CGPath(rect: CGRect(x: -60, y: -45, width: 120, height: 90), transform: nil)
        return Shape(name: "Rectangle",
                     origin: .zero,
                     path: path)
    }

    static var ellipse: Shape {
        let path = CGPath(ellipseIn: CGRect(x: -55, y: -60, width: 110, height: 120), transform: nil)
        return Shape(name: "Ellipse",
                     origin: .zero,
                     path: path)
    }

    static var roundedRect: Shape {
        let path = CGPath(roundedRect: CGRect(x: -45, y: -40, width: 90, height: 80),
                          cornerWidth: 15,
                          cornerHeight: 15,
                          transform: nil)
        return Shape(name: "Rounded Rectangle",
                     origin: .zero,
                     path: path)
    }

    static var randomShape: Shape {
        switch arc4random_uniform(3) {
        case 0: return ellipse
        case 1: return roundedRect
        default: return rectangle
        }
    }
}
