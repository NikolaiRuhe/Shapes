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

        self.model.add(observer: self)
    }
}


fileprivate extension ShapeListController {
    @objc func insertNewObject(_ sender: Any) {
        model.insert(Shape.randomShape, at: 0)
    }
}


// MARK: - model notifications
extension ShapeListController : ModelObserver {
    func modelDidModifyShape(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func modelDidInsertShape(at index: Int) {
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func modelDidRemoveShape(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func modelDidChangeSelection() {
        let selectedRows = tableView.indexPathsForSelectedRows
        if let selectedShapeIndex = model.selectedShapeIndex {
            let indexPath = IndexPath(row: selectedShapeIndex, section: 0)
            if selectedRows != [indexPath] {
                selectedRows?.forEach {
                    tableView.deselectRow(at: $0, animated: true)
                }
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
        } else {
            if let selectedRows = selectedRows {
                selectedRows.forEach {
                    tableView.deselectRow(at: $0, animated: true)
                }
            }
        }
    }
}


// MARK: - UITableViewDelegate/DataSource
extension ShapeListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShapeCell", for: indexPath)

        cell.textLabel!.text = model[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.selectedShapeIndex = indexPath.row
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        model.selectedShapeIndex = nil
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        model.selectedShapeIndex = nil
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        model.selectedShapeIndex = nil
        model.remove(at: indexPath.row)
    }
}
