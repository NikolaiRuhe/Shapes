import UIKit


/// The interaction controller is performing shape interactions.
///
/// It processes touches from the canvas and adjusts the model accordingly.
/// The interaction controller does not set adjust views directly, but lets the
/// canvas do this (by observing the model).

final class InteractionController {
    unowned var canvas: CanvasController
    let touch: UITouch
    var mode: Mode = .idle
    var locationAtBegin: CGPoint = .zero

    enum Mode {
        case idle
        case translation(shapeIndex: Int, originalShape: Shape)
        case point(shapeIndex: Int, elementIndex: Int, pointType: Shape.PointType, originalShape: Shape)
    }

    init(with touch: UITouch, canvasController: CanvasController) {
        self.touch = touch
        self.canvas = canvasController
        self.locationAtBegin = touch.location(in: canvas.view)
    }
}


// MARK: - touch handling
extension InteractionController {

    func processTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        let position = currentPosition

        if let selectedShapeIndex = canvas.model.selectedShapeIndex {
            let shape = canvas.model[shapeAt: selectedShapeIndex]
            let hit = shape.hitTest(position,
                                    includeControlPointsForElementAtIndex: canvas.highlightedElementIndex,
                                    maximumPointDistance: 12)

            switch hit {
            case .inside:
                mode = .translation(shapeIndex: selectedShapeIndex, originalShape: shape)
                canvas.highlightElement(at: nil)
                return true

            case .point(var elementIndex, let pointType):
                mode = .point(shapeIndex: selectedShapeIndex,
                              elementIndex: elementIndex,
                              pointType: pointType,
                              originalShape: shape)
                if pointType == .controlPoint0 {
                    elementIndex -= 1
                }
                canvas.highlightElement(at: elementIndex)
                return true

            case .outside:
                break
            }
        }

        guard let hitShapeIndex = canvas.model.indexOfShape(at: position) else {
            canvas.model.deselectShape()
            canvas.endInteraction()
            return false
        }

        canvas.model.selectShape(at: hitShapeIndex)
        mode = .translation(shapeIndex: hitShapeIndex, originalShape: canvas.model[shapeAt: hitShapeIndex])
        return true
    }

    func processTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard touches.contains(touch) else { return false }

        switch mode {
        case .idle:
            return false

        case .translation(let shapeIndex, let originalShape):
            canvas.model[shapeAt: shapeIndex].origin = originalShape.origin + currentTranslation
            return true

        case .point(let shapeIndex, let elementIndex, let pointType, let originalShape):
            let newPath = originalShape.path.translatingPathElement(at: elementIndex,
                                                                    type: pointType,
                                                                    by: currentTranslation)
            canvas.model[shapeAt: shapeIndex].path = newPath

            return true
        }
    }

    func processTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        canvas.endInteraction()
        return true
    }

    func processTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        defer {
            canvas.endInteraction()
        }

        switch mode {
        case .idle:
            return false

        case .translation(let shapeIndex, let originalShape),
             .point(let shapeIndex, _, _, let originalShape):

            canvas.model[shapeAt: shapeIndex].origin = originalShape.origin
            return true
        }
    }
}


fileprivate extension InteractionController {

    var currentPosition: CGPoint {
        return touch.location(in: canvas.view) - canvas.view.bounds.mid
    }

    var currentTranslation: CGVector {
        return touch.location(in: canvas.view) - locationAtBegin
    }
}
