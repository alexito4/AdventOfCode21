import Foundation

func identity<T>(_ input: T) -> T { input }

import Then
struct Point: Hashable, CustomStringConvertible, Then {
    var x: Int
    var y: Int

    var description: String {
        "(\(x), \(y))"
    }

    static func * (_ point: Point, _ number: Int) -> Point {
        .init(x: point.x * number, y: point.y * number)
    }
}

struct Pair<L: Hashable, R: Hashable>: Hashable {
    let left: L
    let right: R
}
