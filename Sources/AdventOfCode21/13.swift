import Foundation
import Parsing

let day13 = Problem(
    day: 13,
    rawExample: """
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5

    """,
    parse: parsePaper(_:),
    solve: firstFoldAndCount(_:), // 17  /  607
    solve2: foldAndCode(_:) // O      /    CPZLPFZL
)

struct Paper {
    var dots: Set<Point>
    var folds: [Fold]

    enum Fold {
        case up(Int)
        case left(Int)
    }
}

private func parsePaper(_ input: String) -> Paper {
    let pointParser = Int.parser()
        .skip(",")
        .take(Int.parser())
        .map(Point.init(x:y:))

    let pointsParser = Many(
        pointParser,
        separator: "\n"
    ).map(Set.init)

    let foldParser = Skip("fold along ")
        .take(
            "x".map { Paper.Fold.left(0) }
                .orElse("y".map { .up(0) })
        )
        .skip("=")
        .take(Int.parser())
        .map { fold, number -> Paper.Fold in
            switch fold {
            case .left: return .left(number)
            case .up: return .up(number)
            }
        }

    let foldsParser = Many(
        foldParser,
        separator: "\n"
    )

    let parser = pointsParser
        .skip(Whitespace().pullback(\.utf8))
        .take(foldsParser)
        .skipFinalLine()
        .map(Paper.init(dots:folds:))

    return parser.fullParse(input)!
}

// How many dots are visible after completing just the first fold instruction on your transparent paper?
private func firstFoldAndCount(_ input: Paper) throws -> Int {
    let firstFold = input.folds.first!
    var newDots = input.dots
    fold(dots: &newDots, at: firstFold)
    return newDots.count
}

// What code do you use to activate the infrared thermal imaging camera system?
private func foldAndCode(_ input: Paper) throws -> Int {
    // Fully fold
    var finalDots = input.dots
    for f in input.folds {
        fold(dots: &finalDots, at: f)
    }

    // Print it?
    let maxX = finalDots.max(by: binaryCompare(\.x, by: <))!.x
    let maxY = finalDots.max(by: binaryCompare(\.y, by: <))!.y
    var buffer = ""
    for y in 0...maxY {
        for x in 0...maxX {
            if finalDots.contains(Point(x: x, y: y)) {
                buffer.append("#")
            } else {
                buffer.append(".")
            }
            buffer.append("")
        }
        buffer.append("\n")
    }
    print(buffer)

    // We should have a mapping for each letter of the abecedary to points,
    // then take a slice of the horizontal output, normalise those points to x=0 and look for them in the map.
    // But we can just let my eyes do that :D
    return 0 // try notYet(input)
}

private func fold(dots: inout Set<Point>, at fold: Paper.Fold) {
    for dot in dots {
        switch fold {
        case let .up(axis):
            if dot.y > axis {
                let distanceToAxis = dot.y - axis
                let newY = axis - distanceToAxis
                dots.remove(dot)
                dots.insert(Point(x: dot.x, y: newY))
            }
        case let .left(axis):
            if dot.x > axis {
                let distanceToAxis = dot.x - axis
                let newX = axis - distanceToAxis
                dots.remove(dot)
                dots.insert(Point(x: newX, y: dot.y))
            }
        }
    }
}
