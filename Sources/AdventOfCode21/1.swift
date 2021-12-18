import Algorithms
import Foundation

let day1 = Problem(
    day: 1,
    example: [
        199,
        200,
        208,
        210,
        200,
        207,
        240,
        269,
        260,
        263,
    ],
    parse: {
        $0
            .split(separator: "\n")
            .map { Int($0)! }
    },
    solve: countIncreases,
    solve2: countIncreasesWindows
)

func countIncreases(measurments: [Int]) -> Int {
    measurments
        .dropFirst()
        .reduce(into: (increases: 0, previous: measurments[0])) { partialResult, measurment in
            if measurment > partialResult.previous {
                partialResult.increases += 1
            }
            partialResult.previous = measurment
        }
        .increases
}

func countIncreasesWindows(measurments: [Int]) -> Int {
    measurments
        .windows(ofCount: 3)
        .map { $0.reduce(0, +) }
//        .debug()
        .let(countIncreases(measurments:))
//        .debug()
}
