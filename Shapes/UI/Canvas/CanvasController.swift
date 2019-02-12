import UIKit


class CanvasController: UIViewController {

    let model: ShapeModel
    var shapeViews: [ShapeView] = []
    var interactionController: InteractionController? = nil

    override init(nibName: String?, bundle: Bundle?) {
        self.model = ScopedConfiguration.current.model
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        self.model = ScopedConfiguration.current.model
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.model.add(observer: self)
        updateAllViews()
    }

    deinit {
        interactionController = nil
    }
}


// MARK: - interaction
extension CanvasController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        eventProcessingScope: do {
            // we only start a new interaction if there's not an ongoing one
            guard interactionController == nil else { break eventProcessingScope }

            // we only start a new interaction if there's exactly one touch
            guard event?.allTouches?.count == 1 else { break eventProcessingScope }

            // we only start a new interaction if there is a touch beginning now
            guard let touch = touches.first else { break eventProcessingScope }

            guard beginInteraction(with: touch).processTouchesBegan(touches, with: event) else {
                break eventProcessingScope
            }

            // we processed the event successfully
            return
        }

        // The event was not for us. Pass it up the responder chain.
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let interactionController = interactionController,
            interactionController.processTouchesMoved(touches, with: event) {
            return
        }
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let interactionController = interactionController,
            interactionController.processTouchesEnded(touches, with: event) {
            return
        }
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let interactionController = interactionController,
            interactionController.processTouchesCancelled(touches, with: event) {
            return
        }
        super.touchesCancelled(touches, with: event)
    }

    fileprivate func beginInteraction(with touch: UITouch) -> InteractionController {
        let interactionController = InteractionController(with: touch, canvasController: self)
        self.interactionController = interactionController
        return interactionController
    }

    func endInteraction() {
        interactionController = nil
    }
}


// MARK: - model notifications
extension CanvasController : ModelObserver {
    func modelDidModifyShape(at index: Int) {
        updateView(at: index)
    }

    func modelDidInsertShape(at index: Int) {
        endInteraction()
        updateAllViews()
    }

    func modelDidRemoveShape(at index: Int) {
        endInteraction()
        updateAllViews()
    }

    func modelDidChangeSelection() {
        updateSelection()
    }
}


fileprivate extension CanvasController {

    func updateView(at index: Int) {
        shapeViews[index].update(from: model[shapeAt: index])
    }

    func updateAllViews() {
        shapeViews.forEach {
            $0.removeFromSuperview()
        }
        shapeViews = []

        for shape in model.shapes {
            let shapeView = ShapeView()
            view.addSubview(shapeView)
            shapeView.update(from: shape)
            shapeViews.append(shapeView)
        }

        if let index = model.selectedShapeIndex {
            shapeViews[index].highlight = .selected
        }
    }

    func updateSelection() {
        for (index, shapeView) in shapeViews.enumerated() {
            let isSelected = index == model.selectedShapeIndex
            shapeView.highlight = isSelected ? .selected : .default
        }
    }
}
