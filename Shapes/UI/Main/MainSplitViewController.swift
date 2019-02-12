import UIKit


/// Performs loading of initial view controllers.

class MainSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = ShapeModel()

        let masterController: UIViewController = ScopedConfiguration.provide {
            $0.model = model
            return UIStoryboard(name: "ShapeList", bundle: nil).instantiateInitialViewController()!
        }

        let detailController: UIViewController = ScopedConfiguration.provide {
            $0.model = model
            return UIStoryboard(name: "Canvas", bundle: nil).instantiateInitialViewController()!
        }

        viewControllers = [masterController, detailController]
    }
}
