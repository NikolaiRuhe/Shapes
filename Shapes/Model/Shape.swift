import Foundation
import CoreGraphics


public struct Shape {
    var name: String
    var origin: CGPoint
    var path: CGPath
}


public extension Shape {
    enum PointType {
        case pointOnPath
        case controlPoint0
        case controlPoint1
    }

    enum HitResult {
        case point(elementIndex: Int, pointType: PointType)
        case inside
        case outside
    }

    func hitTest(_ point: CGPoint, includeControlPointsForElementAtIndex controlPointsElementIndex: Int?, maximumPointDistance: CGFloat) -> HitResult {

        let localPosition = point - origin as CGPoint
        let maximumSquaredDistance = maximumPointDistance * maximumPointDistance

        func pointHitTest(_ point: CGPoint) -> Bool {
            return (point - localPosition).squaredLength < maximumSquaredDistance
        }

        var currentIndex = 0
        var result: HitResult? = nil
        path.applyWithBlock {
            pathElementPtr in

            defer { currentIndex += 1 }
            if result != nil { return }

            switch pathElementPtr.pointee.type {
            case .moveToPoint:
                if pointHitTest(pathElementPtr.pointee.points[0]) {
                    result = .point(elementIndex: currentIndex, pointType: .pointOnPath)
                }

            case .addLineToPoint:
                if pointHitTest(pathElementPtr.pointee.points[0]) {
                    result = .point(elementIndex: currentIndex, pointType: .pointOnPath)
                }

            case .addCurveToPoint:
                if controlPointsElementIndex == currentIndex {
                    if pointHitTest(pathElementPtr.pointee.points[1]) {
                        result = .point(elementIndex: currentIndex, pointType: .controlPoint1)
                        break
                    }
                } else if controlPointsElementIndex == currentIndex - 1 {
                    if pointHitTest(pathElementPtr.pointee.points[0]) {
                        result = .point(elementIndex: currentIndex, pointType: .controlPoint0)
                        break
                    }
                }

                if pointHitTest(pathElementPtr.pointee.points[2]) {
                    result = .point(elementIndex: currentIndex, pointType: .pointOnPath)
                }

            case .closeSubpath, .addQuadCurveToPoint:
                break
            }
        }

        if let result = result {
            return result
        }

        let isInside = path.contains(localPosition,
                                     using: .winding,
                                     transform: .identity)
        
        return isInside ? .inside : .outside
    }

    func contains(_ point: CGPoint) -> Bool {
        return path.contains(point - origin,
                             using: .winding,
                             transform: .identity)
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


extension CGPath {

    func translatingPathElement(at elementIndex: Int, type: Shape.PointType, by offset: CGVector) -> CGPath {

        var currentIndex = 0
        var result = CGMutablePath()

        applyWithBlock {
            pathElementPtr in

            defer { currentIndex += 1 }

            switch pathElementPtr.pointee.type {
            case .moveToPoint:
                var point = pathElementPtr.pointee.points.pointee
                if elementIndex == currentIndex { point += offset }
                result.move(to: point)

            case .addLineToPoint:
                var point = pathElementPtr.pointee.points.pointee
                if elementIndex == currentIndex { point += offset }
                result.addLine(to: point)

            case .addCurveToPoint:
                var point0 = pathElementPtr.pointee.points[0]
                var point1 = pathElementPtr.pointee.points[1]
                var point2 = pathElementPtr.pointee.points[2]

                switch type {
                case .pointOnPath:
                    if elementIndex == currentIndex {
                        point1 += offset
                        point2 += offset
                    } else if elementIndex == currentIndex - 1 {
                        point0 += offset
                    }
                case .controlPoint0:
                    if elementIndex == currentIndex {
                        point0 += offset
                    } else if elementIndex == currentIndex + 1 {
                        point1 -= offset
                    }
                case .controlPoint1:
                    if elementIndex == currentIndex {
                        point1 += offset
                    } else if elementIndex == currentIndex - 1 {
                        point0 -= offset
                    }
                }
                result.addCurve(to: point2,
                                control1: point0,
                                control2: point1)

            case .closeSubpath:
                result.closeSubpath()

            case .addQuadCurveToPoint:
                preconditionFailure("we do not support quad curves")
            }
        }

        return result
    }
}
