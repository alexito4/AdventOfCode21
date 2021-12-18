import Algorithms
import Foundation
import Overture
import Parsing

let day14 = Problem(
    day: 14,
    rawExample: """
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C

    """,
    parse: parse(_:),
    solve: flip(curry(calculate(_:steps:)))(10), // 1588    |  3906
    solve2: flip(curry(calculate(_:steps:)))(40)
)

struct PolymerInstructions {
    let template: String
    let insertionRules: [String: Character]
}

private struct ElementPair: Hashable, CustomStringConvertible {
    var first: Character
    var last: Character
    var isStart: Bool
    var isEnd: Bool

    var string: String {
        "\(first)\(last)"
    }

    var description: String {
        "\(first)\(last) - \(isStart) \(isEnd)"
    }
}

private func parse(_ input: String) -> PolymerInstructions {
    let templateParser = PrefixUpTo("\n")

    let ruleParser = PrefixUpTo(" ")
        .skip(" -> ")
        .take(PrefixUpTo("\n"))
        .map { (String($0), $1.first!) }

    let rulesParser = Many(
        ruleParser,
        separator: "\n"
    )

    let parser = templateParser
        .skip(Whitespace().pullback(\.utf8))
        .take(rulesParser)
        .skipFinalLine()
        .map { PolymerInstructions(template: String($0), insertionRules: Dictionary(uniqueKeysWithValues: $1)) }

    return parser.fullParse(input)!
}

// What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
private func calculate(_ input: PolymerInstructions, steps: Int) throws -> Int {
    let adjacentPairs = input.template
        .lazy
        .adjacentPairs()

    var pairs = adjacentPairs
        .enumerated()
        .map {
            (
                ElementPair(
                    first: $1.0,
                    last: $1.1,
                    isStart: $0 == 0,
                    isEnd: $0 == adjacentPairs.count - 1
                ),
                1
            )
        }
        .let { Dictionary($0, uniquingKeysWith: { $0 + $1 }) }
//        .debug()

    for _ in 1...steps {
        processStep(pairs: &pairs, rules: input.insertionRules)
    }

    // Count occurrences
    var counts = [Character: Int]()
    for (pair, count) in pairs {
        counts[pair.first, default: 0] += count
        counts[pair.last, default: 0] += count
    }
    // Divide by 2 since each charater shows up twice in consequent pairs
    counts = counts.mapValues { $0 / 2 }
    // Fix start and end
    let start = pairs.first(where: { $0.key.isStart })!
    counts[start.key.first]! += start.value
    let end = pairs.first(where: { $0.key.isEnd })!
    counts[end.key.last]! += end.value
    //  B occurs 1749 times, C occurs 298 times, H occurs 161 times, and N occurs 865 times
//    print(counts)

    let (least, most) = counts.minAndMax(by: binaryCompare(\.value, by: <))!
    let output = most.value - least.value
    return output
}

private func processStep(pairs: inout [ElementPair: Int], rules: [String: Character]) {
    var newPairs = [ElementPair: Int]()
    for (pair, count) in pairs {
        if let insertion = rules[pair.string] {
            newPairs[ElementPair(first: pair.first, last: insertion, isStart: pair.isStart, isEnd: false), default: 0] += count
            newPairs[ElementPair(first: insertion, last: pair.last, isStart: false, isEnd: pair.isEnd), default: 0] += count
        } else {
            newPairs[pair, default: 0] += count
        }
    }
    pairs = newPairs
}
