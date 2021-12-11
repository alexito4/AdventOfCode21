import Foundation

func identity<T>(_ input: T) -> T { input }

import Then
struct Point: Hashable, CustomStringConvertible, Then {
    var x: Int
    var y: Int

    var description: String {
        "(\(x), \(y))"
    }
}

struct Pair<L: Hashable, R: Hashable>: Hashable {
    let left: L
    let right: R
}

