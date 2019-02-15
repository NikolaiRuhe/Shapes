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
    fileprivate(set) var selectedShapeIndex: Int?
    fileprivate var observers: [WeakObserver] = []
}


// MARK: - Model observing and notifications
public protocol ModelObserver: class {
    func observeModelChange(_ change: ShapeModel.Change)
}

extension ShapeModel {

    public struct Change {
        let phase: Phase
        let kind: Kind

        enum Phase {
            case pre
            case post
        }

        enum Kind {
            case selection(oldIndex: Int?, newIndex: Int?)

            case insertShape(shapeIndex: Int)
            case removeShape(shapeIndex: Int)

            case path(shapeIndex: Int)
            case origin(shapeIndex: Int)
            case name(shapeIndex: Int)
        }
    }

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

    func sendNotification(phase: Change.Phase, kind: Change.Kind) {
        observers.forEach {
            $0.wrapped?.observeModelChange(Change(phase: phase, kind: kind))
        }
    }
}


// MARK: - Public shapes access
public extension ShapeModel {

    subscript(shapeAt index: Int) -> Shape {
        get {
            return shapes[index]
        }

        set {
            let originDidChange = shapes[index].origin != newValue.origin
            let pathDidChange = shapes[index].path != newValue.path
            let nameDidChange = shapes[index].name != newValue.name
            guard pathDidChange || originDidChange || nameDidChange else { return }

            if pathDidChange { sendNotification(phase: .pre, kind: .path(shapeIndex: index)) }
            if originDidChange { sendNotification(phase: .pre, kind: .origin(shapeIndex: index)) }
            if nameDidChange { sendNotification(phase: .pre, kind: .name(shapeIndex: index)) }
            shapes[index] = newValue
            if nameDidChange { sendNotification(phase: .post, kind: .origin(shapeIndex: index)) }
            if originDidChange { sendNotification(phase: .post, kind: .origin(shapeIndex: index)) }
            if pathDidChange { sendNotification(phase: .post, kind: .path(shapeIndex: index)) }
        }
    }

    var selectedShape: Shape? {
        guard let selectedShapeIndex = selectedShapeIndex else { return nil }
        return shapes[selectedShapeIndex]
    }

    func selectShape(at index: Int) {
        guard selectedShapeIndex != index else { return }

        let oldValue = selectedShapeIndex
        sendNotification(phase: .pre, kind: .selection(oldIndex: oldValue, newIndex: index))
        selectedShapeIndex = index
        sendNotification(phase: .post, kind: .selection(oldIndex: oldValue, newIndex: index))
    }

    func deselectShape() {
        guard let selectedShapeIndex = selectedShapeIndex else { return }

        sendNotification(phase: .pre, kind: .selection(oldIndex: selectedShapeIndex, newIndex: nil))
        self.selectedShapeIndex = nil
        sendNotification(phase: .post, kind: .selection(oldIndex: selectedShapeIndex, newIndex: nil))

    }

    subscript(shapeAt position: CGPoint) -> Shape? {
        guard let index = indexOfShape(at: position) else { return nil }
        return shapes[index]
    }

    func insert(_ shape: Shape, at index: Int) {
        sendNotification(phase: .pre, kind: .insertShape(shapeIndex: index))
        shapes.insert(shape, at: index)
        sendNotification(phase: .post, kind: .insertShape(shapeIndex: index))
    }

    func remove(at index: Int) {
        sendNotification(phase: .pre, kind: .removeShape(shapeIndex: index))
        shapes.remove(at: index)
        sendNotification(phase: .post, kind: .removeShape(shapeIndex: index))
    }

    func indexOfShape(at position: CGPoint) -> Int? {
        return shapes.enumerated().first {
            _, shape in
            return shape.contains(position)
        }?.offset
    }
}
