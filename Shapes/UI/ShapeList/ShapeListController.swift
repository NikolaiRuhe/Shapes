import UIKit


/// Presents the textual list of user created shapes.
///
/// Lets the user edit the list and updates the model accordingly.

class ShapeListController: UITableViewController {

    let model: ShapeModel

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
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
}


extension ShapeListController {

    @objc
    func insertNewObject(_ sender: Any) {
        model.shapes.insert(Shape(name: Date().description), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}


// MARK: - UITableViewDelegate/DataSource
extension ShapeListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.shapes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShapeCell", for: indexPath)

        let object = model.shapes[indexPath.row]
        cell.textLabel!.text = object.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigationController = splitViewController!.viewControllers.last as! UINavigationController
        let canvasController = navigationController.topViewController as! CanvasController
        canvasController.selectedIndex = indexPath.row
        canvasController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        canvasController.navigationItem.leftItemsSupplementBackButton = true
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        model.shapes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
