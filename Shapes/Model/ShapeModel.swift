import Foundation
import CoreGraphics


/// This type represents the shared model that view controllers use
/// to display and edit the list of shapes.
///
/// Its main purpose is to have a common place to store objects and to inform
/// view controllers (observers) about modifications.
///
/// As this class also stores the current selection its more of a view model
/// than a data model. This is due to the constrained scope of this test app.

public class ShapeModel {
    fileprivate(set) var shapes: [Shape] = []
    fileprivate var observers: [WeakObserver] = []
    var selectedShapeIndex: Int? {
        didSet {
            if selectedShapeIndex != oldValue {
                notify {
                    $0.modelDidChangeSelection()
                }
            }
        }
    }
}

// MARK: - Model observing and notifications
extension ShapeModel {
    fileprivate struct WeakObserver {
        weak var wrapped: ModelObserver?
    }

    func add(observer: ModelObserver) {
        observers.append(WeakObserver(wrapped: observer))
    }

    func remove(observer: ModelObserver) {
        observers.removeAll {
            $0.wrapped === observer
        }
    }

    func notify(_ body: (ModelObserver) -> Void) {
        observers.forEach {
            if let observer = $0.wrapped {
                body(observer)
            }
        }
    }
}


// MARK: - Public shapes access
public extension ShapeModel {

    var count: Int {
        return shapes.count
    }

    subscript(shapeAt index: Int) -> Shape {
        get {
            return shapes[index]
        }

        set {
            shapes[index] = newValue
            notify { $0.modelDidModifyShape(at: index) }
        }
    }

    var selectedShape: Shape? {
        guard let selectedShapeIndex = selectedShapeIndex else { return nil }
        return shapes[selectedShapeIndex]
    }

    subscript(shapeAt position: CGPoint) -> Shape? {
        guard let index = indexOfShape(at: position) else { return nil }
        return shapes[index]
    }

    func insert(_ shape: Shape, at index: Int) {
        shapes.insert(shape, at: index)
        notify { $0.modelDidInsertShape(at: index) }
    }

    func remove(at index: Int) {
        shapes.remove(at: index)
        notify { $0.modelDidRemoveShape(at: index) }
    }

    func indexOfShape(at position: CGPoint) -> Int? {
        return shapes.enumerated().first {
            _, shape in
            return shape.contains(position)
        }?.offset
    }
}


public protocol ModelObserver: class {
    func modelDidModifyShape(at index: Int)
    func modelDidInsertShape(at index: Int)
    func modelDidRemoveShape(at index: Int)
    func modelDidChangeSelection()
}
