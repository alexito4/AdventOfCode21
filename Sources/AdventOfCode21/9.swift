import Algorithms
import Foundation
import Parsing

let day9 = Problem(
    day: 9,
    rawExample: """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """,
    parse: parseHeightmap(_:),
    solve: sumRiskOfLowPoints(_:), //  15    |   452
    solve2: find3LargestBasins(_:)
)

private func parseHeightmap(_ input: String) -> HeightMap {
    let parseDigit = First<Substring>()
        .map(String.init).map { $0[...] }
        .pipe(Int.parser())

    let parseLine = Many(parseDigit, atLeast: 1)

    let parser = Many(
        parseLine,
        atLeast: 1,
        separator: "\n"
    )
    .finalLine()

//    parser.test(input)

    return parser.fullParse(input)!
}

// What is the sum of the risk levels of all low points on your heightmap?
private func sumRiskOfLowPoints(_ heightmap: HeightMap) throws -> Int {
//    print(heightmap.draw())

    var totalRiskLevel = 0
    for y in heightmap.indices {
        for x in heightmap[y].indices {
            if heightmap.hasLowpointAt(x: x, y: y) {
//                print("Low \(x), \(y): \(heightmap[x: x, y: y]) | risk: \(heightmap.riskLevelAt(x: x, y: y))")
                totalRiskLevel += heightmap.riskLevelAt(x: x, y: y)
            }
        }
    }
    return totalRiskLevel
}

private func find3LargestBasins(_ heightmap: HeightMap) throws -> Int {
    var basinSizes = [Int]()
    for y in heightmap.indices {
        for x in heightmap[y].indices {
            if heightmap.hasLowpointAt(x: x, y: y) {
                let basinSize = heightmap.sizeOfBasinAt(x: x, y: y)
//                print("Low (\(x), \(y)) : \(heightmap[x: x, y: y]) | basin size: \(basinSize)")
                basinSizes.append(basinSize)
            }
        }
    }

    return basinSizes
        .sorted(by: binaryCompare(\.self, by: >))
        .prefix(3)
        .reduce(1, *)
//        .debug()
}

// MARK: Support code

typealias HeightMap = [[Int]]

private extension HeightMap {
    func riskLevelAt(x: Int, y: Int) -> Int {
        self[x: x, y: y] + 1
    }

    func neightbouringPoints(x: Int, y: Int) -> _Neightbours<Point?> {
        .init( // lazy dev, try acces instead of doing the check ^^'
            up: Point(x: x, y: y - 1).let { self[safe: $0] == nil ? nil : $0 },
            right: Point(x: x + 1, y: y).let { self[safe: $0] == nil ? nil : $0 },
            down: Point(x: x, y: y + 1).let { self[safe: $0] == nil ? nil : $0 },
            left: Point(x: x - 1, y: y).let { self[safe: $0] == nil ? nil : $0 }
        )
    }

    func neightboursOf(x: Int, y: Int) -> Neightbours {
        let points = neightbouringPoints(x: x, y: y)
        return Neightbours(
            up: points.up.flatMap { self[safe: $0] },
            right: points.right.flatMap { self[safe: $0] },
            down: points.down.flatMap { self[safe: $0] },
            left: points.left.flatMap { self[safe: $0] }
        )
    }

    func hasLowpointAt(x: Int, y: Int) -> Bool {
        let this = self[x: x, y: y]
        let neightbours = neightboursOf(x: x, y: y)
        guard neightbours.up ?? Int.max > this else { return false }
        guard neightbours.right ?? Int.max > this else { return false }
        guard neightbours.down ?? Int.max > this else { return false }
        guard neightbours.left ?? Int.max > this else { return false }
        return true
    }

    // precondition: x, y is a lowpoint
    func sizeOfBasinAt(x: Int, y: Int) -> Int {
        var toVisit = Set<Point>([Point(x: x, y: y)])
        var visited = Set<Point>()

        var basinSize = 0
        while !toVisit.isEmpty {
//            defer {
//                print(basinSize)
//                print("----")
//            }
            let point = toVisit.popFirst()!
//            print(point, "visiting")

            // Don't visit the same multiple times
            guard !visited.contains(point) else {
//                print(point, "skiped")
                continue
            }
            visited.insert(point)

            // Height 9 is not part of the basin
            let height = self[safe: point]!
            guard height < 9 else {
//                print(point, "not part of the basin \(height)")
                continue
            }

//            print(point, "counted")
            basinSize += 1

            let neightbours = neightbouringPoints(x: point.x, y: point.y)
            if let up = neightbours.up {
                toVisit.insert(up)
            }
            if let right = neightbours.right {
                toVisit.insert(right)
            }
            if let down = neightbours.down {
                toVisit.insert(down)
            }
            if let left = neightbours.left {
                toVisit.insert(left)
            }
        }

        return basinSize
    }
}

private typealias Neightbours = _Neightbours<Int?>
private struct _Neightbours<T> {
    let up: T
    let right: T
    let down: T
    let left: T
}
