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
    }

    init(with touch: UITouch, canvasController: CanvasController) {
        self.touch = touch
        self.canvas = canvasController
        self.locationAtBegin = touch.location(in: canvas.view)
    }
}


extension InteractionController {

    func processTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        let position = currentPosition

        if let selectedShapeIndex = canvas.model.selectedShapeIndex {
            let shape = canvas.model[shapeAt: selectedShapeIndex]
            if shape.contains(position) {
                mode = .translation(shapeIndex: selectedShapeIndex, originalShape: shape)
                return true
            }
        }

        guard let hitShapeIndex = canvas.model.indexOfShape(at: position) else {
            canvas.model.selectedShapeIndex = nil
            canvas.endInteraction()
            return false
        }

        canvas.model.selectedShapeIndex = hitShapeIndex
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
        }
    }

    func processTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        canvas.endInteraction()
        return true
    }

    func processTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        canvas.endInteraction()
        return true
    }

    var currentPosition: CGPoint {
        return touch.location(in: canvas.view) - canvas.view.bounds.mid
    }

    var currentTranslation: CGVector {
        return touch.location(in: canvas.view) - locationAtBegin
    }
}
