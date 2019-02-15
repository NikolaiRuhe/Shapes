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

        model.add(observer: self)
    }
}


fileprivate extension ShapeListController {
    @objc func insertNewObject(_ sender: Any) {
        model.insert(Shape.randomShape, at: 0)
    }
}


// MARK: - model notifications
extension ShapeListController : ModelObserver {
    func observeModelChange(_ change: ShapeModel.Change) {
        switch (change.phase, change.kind) {

        case (.pre, .selection(let oldIndex, _)):
            guard let oldIndex = oldIndex else { break }
            tableView.deselectRow(at: IndexPath(row: oldIndex, section: 0), animated: false)

        case (.post, .selection(_, let newIndex)):
            guard let newIndex = newIndex else { break }
            tableView.selectRow(at: IndexPath(row: newIndex, section: 0), animated: false, scrollPosition: .none)

        case (.post, .insertShape(let shapeIndex)):
            tableView.insertRows(at: [IndexPath(row: shapeIndex, section: 0)], with: .automatic)

        case (.post, .removeShape(let shapeIndex)):
            tableView.deleteRows(at: [IndexPath(row: shapeIndex, section: 0)], with: .automatic)

        case (.post, .name(let shapeIndex)):
            tableView.reloadRows(at: [IndexPath(row: shapeIndex, section: 0)], with: .automatic)

        default:
            break
        }
    }
}


// MARK: - UITableViewDelegate/DataSource
extension ShapeListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.shapes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShapeCell", for: indexPath)

        cell.textLabel!.text = model[shapeAt: indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.selectShape(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        model.deselectShape()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        model.deselectShape()
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        model.deselectShape()
        model.remove(at: indexPath.row)
    }
}
