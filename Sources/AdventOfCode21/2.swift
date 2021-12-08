import Foundation
import Overture
import Parsing

let day2 = Problem(
    day: 2,
    example: """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """,
    parse: { $0 },
    solve: pipe(parseInstructions, calculatePosition),
    solve2: pipe(parseInstructions, calculatePositionAndAim)
)

struct Action {
    let direction: Direction
    let magnitude: Int

    enum Direction {
        case forward
        case down
        case up
    }
}

private func parseInstructions(_ instructions: String) -> [Action] {
    let direction = StartsWith<String.SubSequence>("forward").map { Action.Direction.forward }
        .orElse(StartsWith("down").map { .down })
        .orElse(StartsWith("up").map { .up })

    let action = direction
        .skip(" ")
        .take(Int.parser())
        .map { direction, magnitude in
            Action(direction: direction, magnitude: magnitude)
        }

    let parser = Many(
        action
            .skip(Optional.parser(of: "\n"))
    )
    .skip(End())

    var input = instructions[...]
    let output = parser.parse(&input) ?? []
    return output
}

func calculatePosition(_ actions: [Action]) -> Int {
    let (horizontal, depth) = actions.reduce(into: (0, 0)) { partialResult, action in
        switch action.direction {
        case .forward: partialResult.0 += action.magnitude
        case .up: partialResult.1 -= action.magnitude
        case .down: partialResult.1 += action.magnitude
        }
    }
    return horizontal * depth
}

func calculatePositionAndAim(_ actions: [Action]) -> Int {
    let (horizontal, depth, _) = actions.reduce(into: (h: 0, 0, 0)) { partialResult, action in
        switch action.direction {
        case .forward:
            partialResult.0 += action.magnitude
            partialResult.1 += partialResult.2 * action.magnitude
        case .up: partialResult.2 -= action.magnitude
        case .down: partialResult.2 += action.magnitude
        }
    }
    return horizontal * depth
}
