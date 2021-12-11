import BitArrayModule
import Foundation

extension BitArray {
    var binaryRepresentation: Int {
        map { $0 ? "1" : "0" }
            .joined()
            .let { Int($0)! }
    }

    var decimalRepresentation: Int {
        map { $0 ? "1" : "0" }
            .joined()
            .let { Int($0, radix: 2)! }
    }
}

extension Array {
    mutating func mutateEach(by transform: (inout Element) throws -> LoopReturn) rethrows {
        for i in indices {
            switch try transform(&self[i]) {
            case .continue: continue
            case .break: break
            }
        }
    }
}

enum LoopReturn {
    case `continue`
    case `break`
}

extension Collection where Element == Int {
    func sum() -> Element {
        reduce(0, +)
    }

    func average() -> Double {
        let sum = Double(sum())
        return sum / Double(count)
    }

    func median() -> Double {
        let count = Double(count)
        if count == 0 { return 0 }
        let sorted = sorted { $0 < $1 }

        if count.truncatingRemainder(dividingBy: 2) == 0 {
            // Even number of items - return the mean of two middle values
            let leftIndex = Int(count / 2 - 1)
            let leftValue = Double(sorted[leftIndex])
            let rightValue = Double(sorted[leftIndex + 1])
            return (leftValue + rightValue) / 2.0
        } else {
            // Odd number of items - take the middle item.
            return Double(sorted[Int(count / 2)])
        }
    }
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }

    subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }

        return self[index]
    }
}

typealias Map2d = [[Int]]

extension Map2d {
    // Instead of doing double subscript heightmap[y][x] you can use
    // this one to use a more natural x, y.
    subscript(x x: Int, y y: Int) -> Int {
        get {
            self[y][x]
        }
        set {
            self[y][x] = newValue
        }
    }
    
    subscript(safe point: Point) -> Int? {
        get {
            self[safe: point.y]?[safe: point.x]
        }
    }
    
    subscript(point: Point) -> Int {
        get {
            self[point.y][point.x]
        }
        set {
            self[point.y][point.x] = newValue
        }
    }
    
    func points() -> AnyIterator<Point>  {
        var y = 0
        var x = -1
        return AnyIterator {
            x += 1
            if x == self[y].endIndex {
                x = 0
                y += 1
                if y == self.endIndex {
                    return nil
                }
            }
            return Point(x: x, y: y)
        }
    }
    
    func allElements() -> LazyMapSequence<LazySequence<AnyIterator<Point>>.Elements, Int> {
        points().lazy.map { self[$0] }
    }
    
    func forEachPoint(_ f: (Point) -> Void) {
        for y in self.indices {
            for x in self[y].indices {
               f(Point(x: x, y: y))
            }
        }
    }
    
    func adjecentPointsOf(x: Int, y: Int) -> [Point] {
        [ // lazy dev, try acces instead of doing the check ^^'
            Point(x: x, y: y - 1).let { self[safe: $0] == nil ? nil : $0 },         // N
            Point(x: x + 1, y: y - 1).let { self[safe: $0] == nil ? nil : $0 },     // NE
            Point(x: x + 1, y: y).let { self[safe: $0] == nil ? nil : $0 },         // E
            Point(x: x + 1, y: y + 1).let { self[safe: $0] == nil ? nil : $0 },     // SE
            Point(x: x, y: y + 1).let { self[safe: $0] == nil ? nil : $0 },         // S
            Point(x: x - 1, y: y + 1).let { self[safe: $0] == nil ? nil : $0 },     // SW
            Point(x: x - 1, y: y).let { self[safe: $0] == nil ? nil : $0 },         // W
            Point(x: x - 1, y: y - 1).let { self[safe: $0] == nil ? nil : $0 }      // NW
        ]
        .compactMap { $0 }
    }
    
    func draw() -> String {
        map {
            $0.map { String($0) }
                .joined()
        }
        .joined(separator: "\n")
    }
}
