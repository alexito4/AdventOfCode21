import Foundation
import Parsing

let day18 = Problem(
    day: 18,
    rawExample: """
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    """, // 4140
//    rawExample: """
//    [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
//    """,
    parse: parse(_:),
    solve: sumMagnitude(_:), // 4140        4132
    solve2: largestMagnitudeOf2(_:) // 3993     4685
)

private func sumMagnitude(_ input: [SFNumber]) throws -> Int {
    // addition
    var addition = input.first!
    addition.reduce()
    for next in input.dropFirst() {
        addition = add(addition, next)
        addition.reduce()
    }

//    print(addition)

    return addition.magnitude()
}

func add(_ l: SFNumber, _ r: SFNumber) -> SFNumber {
    .init(left: .pair(l), right: .pair(r))
}

// What is the largest magnitude of any sum of two different snailfish numbers from the homework assignment?
private func largestMagnitudeOf2(_ input: [SFNumber]) throws -> Int {
    input
        .permutations(ofCount: 2)
        .map { combo -> Int in
            let left = combo[0]
            let right = combo[1]
            var sum = add(left, right)
            sum.reduce()
            return sum.magnitude()
        }
        .max()!
}

extension SFNumber {
    mutating func reduce() {
//        print("before reduce", self.debugDescription)
        var reduced = false
        while !reduced {
            // Explode
            if explode() {
//                print("exploded", self.debugDescription)
                continue
            }

            // Split
            if split() {
//                print("split", self.debugDescription)
                continue
            }

            // If it couldn't explode or split means the number is fully reduced.
            reduced = true
        }
//        print("reduced", self.debugDescription)
    }

    // If any pair is nested inside four pairs, the leftmost such pair explodes.
    mutating func explode() -> Bool {
        _explodePair(level: []) != nil
    }

    mutating func _explodePair(level: [SFNumber.Side]) -> (level: [SFNumber.Side], leftNumber: Int?, rightNumber: Int?)? {
        if level.count == 4 {
            if case let .literal(ln) = left, case let .literal(rn) = right {
                return (level, ln, rn)
            }
            fatalError()
        } else {
            // explode left
            switch left {
            case .literal: break
            case let .pair(subpair):
                if let pending = _explodeReusable(nextLevel: level.appending(.left), current: &self, side: \.left, subpair: subpair) {
                    return pending
                }
            }

            // explode right
            switch right {
            case .literal: break
            case let .pair(subpair):
                return _explodeReusable(nextLevel: level.appending(.right), current: &self, side: \.right, subpair: subpair)
            }

            return nil
        }
    }

    // If any regular number is 10 or greater, the leftmost such regular number splits.
    mutating func split() -> Bool {
        // split left
        switch left {
        case let .literal(number):
            if let new = _split(number) {
                left = .pair(new)
                return true
            }
        case let .pair(subpair):
            var copy = subpair
            if copy.split() {
                left = .pair(copy)
                return true
            }
        }

        // split right
        switch right {
        case let .literal(number):
            if let new = _split(number) {
                right = .pair(new)
                return true
            }
        case let .pair(subpair):
            var copy = subpair
            if copy.split() {
                right = .pair(copy)
                return true
            }
        }

        return false
    }

    func magnitude() -> Int {
        left.magnitude(side: .left) + right.magnitude(side: .right)
    }
}

func _split(_ n: Int) -> SFNumber? {
    if n >= 10 {
        let double = Double(n) / 2
        return SFNumber(left: .literal(Int(double.rounded(.down))), right: .literal(Int(double.rounded(.up))))
    } else {
        return nil
    }
}

// reuse the explode for both sides
func _explodeReusable(
    nextLevel: [SFNumber.Side], current: inout SFNumber, side: WritableKeyPath<SFNumber, SFElement>, subpair: SFNumber
) -> (level: [SFNumber.Side], leftNumber: Int?, rightNumber: Int?)? {
    var copy = subpair
    var pendingNumbers = copy._explodePair(level: nextLevel)
    if let pending = pendingNumbers {
        if nextLevel.count != 4 {
            // If is not the direct parent, make sure to update the subtree
            current[keyPath: side] = .pair(copy)
        }

        if let pendingRight = pending.rightNumber, pending.level[nextLevel.count - 1] != .right {
            // right value is added to the first regular number to the right of the exploding pair (if any)
            if current.right.addToFirstLiteral(pendingRight, on: .left) {
                pendingNumbers?.rightNumber = nil
            }
        }

        // left is discarded
        if let pendingLeft = pending.leftNumber, pending.level[nextLevel.count - 1] != .left {
            // left value is added to the first regular number to the left of the exploding pair (if any)
            if current.left.addToFirstLiteral(pendingLeft, on: .right) {
                pendingNumbers?.leftNumber = nil
            }
        }

        if nextLevel.count == 4 {
            // If is parent of exploded subpair, replace with 0
            current[keyPath: side] = .literal(0)
        }
    }
    return pendingNumbers
}

struct SFNumber: CustomDebugStringConvertible {
    var left: SFElement
    var right: SFElement

    enum Side: Equatable {
        case left
        case right

        var magnitudeMultiplier: Int {
            switch self {
            case .left:
                return 3
            case .right:
                return 2
            }
        }
    }

    var debugDescription: String {
        "> \(_debugDescription)"
    }

    var _debugDescription: String {
        "[\(left._debugDescription),\(right._debugDescription)]"
    }
}

enum SFElement {
    case literal(Int)
    indirect case pair(SFNumber)

    var number: Int? {
        switch self {
        case let .literal(int):
            return int
        case .pair:
            return nil
        }
    }

    mutating func addToFirstLiteral(_ n: Int, on side: SFNumber.Side) -> Bool {
        switch self {
        case let .literal(int):
            self = .literal(int + n)
            return true
        case var .pair(subpair):
            switch side {
            case .left:
                if subpair.left.addToFirstLiteral(n, on: side) {
                    self = .pair(subpair)
                    return true
                } else if subpair.right.addToFirstLiteral(n, on: side) {
                    self = .pair(subpair)
                    return true
                } else {
                    return false
                }
            case .right:
                if subpair.right.addToFirstLiteral(n, on: side) {
                    self = .pair(subpair)
                    return true
                } else if subpair.left.addToFirstLiteral(n, on: side) {
                    self = .pair(subpair)
                    return true
                } else {
                    return false
                }
            }
        }
    }

    var _debugDescription: String {
        switch self {
        case let .literal(number):
            return "\(number)"
        case let .pair(sFNumber):
            return sFNumber._debugDescription
        }
    }

    func magnitude(side: SFNumber.Side) -> Int {
        switch self {
        case let .literal(int):
            return side.magnitudeMultiplier * int
        case let .pair(sFNumber):
            return side.magnitudeMultiplier * sFNumber.magnitude()
        }
    }
}

private func parse(_ input: String) -> [SFNumber] {
    var copy = input[...]

    func _parsePair() -> SFNumber {
        "[".parse(&copy)!
        let left: SFElement
        // parse left
        if let number = Int.parser().parse(&copy) {
            left = .literal(number)
        } else {
            left = .pair(_parsePair())
        }
        ",".parse(&copy)!
        let right: SFElement
        // parse right
        if let number = Int.parser().parse(&copy) {
            right = .literal(number)
        } else {
            right = .pair(_parsePair())
        }
        "]".parse(&copy)!
        return SFNumber(left: left, right: right)
    }

    var numbers: [SFNumber] = []
    while !copy.isEmpty {
        let number = _parsePair()
        numbers.append(number)
//        print(number)
        Newline().pullback(\.utf8).parse(&copy)
    }
    return numbers
}
