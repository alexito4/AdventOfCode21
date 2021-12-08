import Foundation
import Then

extension ArraySlice: Then {}
extension Int: Then {}
extension Double: Then {}
extension String: Then {}
extension Substring: Then {}

extension Optional: Then where Wrapped: Then {}

public extension Then {
    @inlinable
    func `let`<R>(_ block: (Self) throws -> R) rethrows -> R {
        try block(self)
    }
}

@inlinable
public func with<T, R>(_ object: T, _ block: (T) throws -> R) rethrows -> R {
    try block(object)
}

extension Then {
    func debug() -> Self {
        print(self)
        return self
    }
}
