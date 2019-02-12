import UIKit


public extension Shape {
    static let iconSize = CGSize(width: 88, height: 88)

    var icon: UIImage {
        UIGraphicsBeginImageContextWithOptions(Shape.iconSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        let box = path.boundingBoxOfPath
        let scale = min((Shape.iconSize.width - 2) / box.size.width, (Shape.iconSize.height - 2) / box.size.height)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -box.origin.x, y: -box.origin.y)

        context.addPath(path)
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

