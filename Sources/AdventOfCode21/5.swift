import Collections
import Foundation
import Parsing

let day5 = Problem(
    day: 5,
    rawExample: """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """,
    parse: parseVents(_:),
    solve: howManyPointsWith2LinesOverlap(_:), // 5   | 4826
    solve2: howManyPointsWith2LinesOverlapDiagonal(_:) // 12 | 16793
)

struct Line {
    var start: Point
    var end: Point
}

struct Point: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String {
        "(\(x), \(y))"
    }
}

private func parseVents(_ input: String) -> [Line] {
    let pointParser = Int.parser()
        .skip(",")
        .take(Int.parser())
        .map(Point.init(x:y:))

    let lineParser = pointParser
        .skip(" -> ")
        .take(pointParser)
        .map(Line.init(start:end:))

    let parser = Many(lineParser, separator: Parsers.newLine)
        .skip(Rest())

//    parser.test(input)
    var copy = input[...]
    let output = parser.parse(&copy) ?? []
    assert(copy.isEmpty)

    return output
}

private func debugCounts(_ counts: [Point: Int]) {
    _ = counts.keys
        .sorted(by: { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x })
        .map {
            "\($0): \(counts[$0]!)"
        }
        .joined(separator: ", ")
        .debug()
}

private func howManyPointsWith2LinesOverlap(_ lines: [Line]) throws -> Int {
    var counts = [Point: Int]()

    for line in lines {
//        print("Calculating", line)
//        defer { debugCounts(counts) }
        let start = line.start
        let end = line.end

        guard start.x == end.x || start.y == end.y else {
            // Skip diagonal
            continue
        }

        var deltaX = end.x - start.x
        var deltaY = end.y - start.y

        var current = start
        counts[current, default: 0] += 1
        while current != end {
            if abs(deltaX) > 0 {
                current.x += deltaX.signum()
                deltaX -= deltaX.signum()
            } else if abs(deltaY) > 0 {
                current.y += deltaY.signum()
                deltaY -= deltaY.signum()
            }
            counts[current, default: 0] += 1
        }
    }

//        drawBoard(counts)

    let dangerousOverlap = 2
    let numberOfPointsWithMoreOverlap = counts.filter { $0.value >= dangerousOverlap }.count

    return numberOfPointsWithMoreOverlap
}

private func howManyPointsWith2LinesOverlapDiagonal(_ lines: [Line]) throws -> Int {
    var counts = [Point: Int]()

    for line in lines {
//        print("Calculating", line)
//        defer { debugCounts(counts) }
        let start = line.start
        let end = line.end

        var deltaX = end.x - start.x
        var deltaY = end.y - start.y

        var current = start
        counts[current, default: 0] += 1
        func moveX() {
            current.x += deltaX.signum()
            deltaX -= deltaX.signum()
        }
        func moveY() {
            current.y += deltaY.signum()
            deltaY -= deltaY.signum()
        }
        while current != end {
            if abs(deltaX) > 0, abs(deltaY) > 0 {
                moveX()
                moveY()
            } else if abs(deltaX) > 0 {
                moveX()
            } else if abs(deltaY) > 0 {
                moveY()
            }
            counts[current, default: 0] += 1
        }
    }

    drawBoard(counts)

    let dangerousOverlap = 2
    let numberOfPointsWithMoreOverlap = counts.filter { $0.value >= dangerousOverlap }.count

    return numberOfPointsWithMoreOverlap
}

private func drawBoard(_ counts: [Point: Int]) {
    guard !counts.isEmpty else { return }
//    printCounts(counts)

    let maxX = counts.keys.max(by: binaryCompare(\.x, by: <))!.x
    let maxY = counts.keys.max(by: binaryCompare(\.y, by: <))!.y

    print("")
    for y in 0...maxY {
        var line = ""
        for x in 0...maxX {
            let char = counts[Point(x: x, y: y)].map(String.init) ?? "."
            line += "\t\(char)"
        }
        print(line)
    }
    print("")
}
