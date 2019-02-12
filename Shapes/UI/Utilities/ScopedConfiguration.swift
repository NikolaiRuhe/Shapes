import UIKit


/// This class helps with initialization of view controllers from storyboards or nibs.
///
/// Conceptually it is just a simple keyed store for any kind of properties.
/// It provides values needed in initializers where they can't be passed in arguments,
/// like in `init(coder: NSCoder)`. This makes it possible to avoid implicitly unwrapped
/// optionals in many cases.
///
/// - Note: Stolen verbatim from one of my last projects :)

@dynamicMemberLookup
class ScopedConfiguration {

    static private var _current: ScopedConfiguration?

    private init() {}

    static func provide<T>(during body: (ScopedConfiguration) -> T) -> T {
        assert(Thread.isMainThread)
        precondition(ScopedConfiguration._current == nil)

        let configuration = ScopedConfiguration()
        ScopedConfiguration._current = configuration
        let result = body(configuration)
        ScopedConfiguration._current = nil

        return result
    }

    static var current: ScopedConfiguration {
        assert(Thread.isMainThread)
        guard let configuration = _current else {
            preconditionFailure("configuration inaccessible")
        }
        return configuration
    }

    private var _data: [String : Any] = [:]

    subscript<T>(dynamicMember key: String) -> T {
        get { return _data[key] as! T }
        set { _data[key] = newValue }
    }
}
