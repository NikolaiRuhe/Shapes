import UIKit


class CanvasController: UIViewController {

    let model: ShapeModel
    var selectedIndex: Int? {
        didSet { updateView() }
    }

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
        updateView()
    }
}


extension CanvasController {
    func updateView() {
        if let selectedIndex = selectedIndex {
            detailDescriptionLabel?.text = model.shapes[selectedIndex].name
        }
    }
}
