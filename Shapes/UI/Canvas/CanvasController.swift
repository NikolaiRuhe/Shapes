import UIKit


class CanvasController: UIViewController {

    let model: ShapeModel

    override init(nibName: String?, bundle: Bundle?) {
        self.model = ScopedConfiguration.current.model
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        self.model = ScopedConfiguration.current.model
        super.init(coder: coder)
    }

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.model.add(observer: self)
        updateView()
    }
}


extension CanvasController : ModelObserver {
    func modelDidModifyShape(at index: Int) {
        updateView()
    }

    func modelDidInsertShape(at index: Int) {
        updateView()
    }

    func modelDidRemoveShape(at index: Int) {
        updateView()
    }

    func modelDidChangeSelection() {
        updateView()
    }
}


extension CanvasController {
    func updateView() {
        if let selectedIndex = model.selectedShapeIndex {
            detailDescriptionLabel?.text = model[selectedIndex].name
        } else {
            detailDescriptionLabel?.text = ""
        }
    }
}
