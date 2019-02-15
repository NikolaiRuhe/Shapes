import UIKit


/// The `CanvasController` observes the model and fills the view with
/// `ShapeView` instances accordingly. It also forwards touches to its
/// `interactionController` to provide interactivity.

class CanvasController: UIViewController {

    let model: ShapeModel
    fileprivate var shapeViews: [ShapeView] = []
    fileprivate var interactionController: InteractionController? = nil
    fileprivate var layoutSize: CGSize = .zero
    fileprivate(set) var highlightedElementIndex: Int?

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
        model.add(observer: self)
        updateAllViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAllViewsIfNeeded()
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

    func highlightElement(at index: Int?) {
        highlightedElementIndex = index
        updateSelection()
    }
}


// MARK: - model notifications
extension CanvasController : ModelObserver {

    func observeModelChange(_ change: ShapeModel.Change) {
        switch (change.phase, change.kind) {

        case (.post, .path(let index)):
            let shape = model[shapeAt: index]
            shapeViews[index].path = shape.path

        case (.post, .origin (let index)):
            let shape = model[shapeAt: index]
            shapeViews[index].center = shape.origin + view.bounds.mid

        case (.post, .selection):
            highlightedElementIndex = nil
            updateSelection()

        case (.post, .insertShape), (.post, .removeShape):
            endInteraction()
            updateAllViews()

        default:
            break
        }
    }
}


fileprivate extension CanvasController {

    func updateAllViewsIfNeeded() {
        if view.bounds.size != layoutSize {
            updateAllViews()
        }
    }

    func updateAllViews() {
        layoutSize = view.bounds.size

        shapeViews.forEach {
            $0.removeFromSuperview()
        }
        shapeViews = []

        for shape in model.shapes {
            let shapeView = ShapeView()
            view.addSubview(shapeView)
            shapeView.path = shape.path
            shapeView.center = shape.origin + view.bounds.mid
            shapeViews.append(shapeView)
        }

        if let index = model.selectedShapeIndex {
            shapeViews[index].highlight = .selected
        }
    }

    func updateSelection() {
        for (index, shapeView) in shapeViews.enumerated() {
            guard index == model.selectedShapeIndex else {
                shapeView.highlight = .default
                continue
            }

            if let elementIndex = highlightedElementIndex {
                shapeView.highlight = .editing(elementIndex: elementIndex)
            } else {
                shapeView.highlight = .selected
            }
        }
    }
}
