import UIKit


class CanvasController: UIViewController {

    let model: ShapeModel
    var shapeViews: [ShapeView] = []

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
}


extension CanvasController : ModelObserver {
    func modelDidModifyShape(at index: Int) {
        updateAllViews()
    }

    func modelDidInsertShape(at index: Int) {
        updateAllViews()
    }

    func modelDidRemoveShape(at index: Int) {
        updateAllViews()
    }

    func modelDidChangeSelection() {
        updateSelection()
    }
}


extension CanvasController {
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
