import Foundation


/// This type represents the shared model that view controllers use
/// to display and edit the list of shapes.
///
/// Its main purpose is to have a common place to store objects and to inform
/// view controllers (observers) about modifications.

class ShapeModel {
    var shapes: [Shape] = []
    var observers: [ModelObserver] = []
}


struct Shape {
    var name: String
}


protocol ModelObserver: class {
}
