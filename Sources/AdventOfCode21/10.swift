import Foundation

let day10 = Problem(
    day: 10,
    rawExample: """
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
    """,
    parse: identity(_:),
    solve: scoreCorruptionErrors(_:), // 26397   |    268845
    solve2: autocompleteScore(_:) // 288957     |   4038824534
)

// What is the total syntax error score for those errors?
private func scoreCorruptionErrors(_ input: String) throws -> Int {
    let lines = input.split(separator: "\n")
    var totalCorruptionScore = 0
    for line in lines {
        var stack = [Character]()

        for char in line {
            if starts.contains(char) {
                stack.append(char)
            } else {
                assert(ends.contains(char))
                let lastStart = stack.popLast()!
                if startsToEnds[lastStart] != char {
                    // Corrupted!
                    let score = corruptionScore[char]!
//                    print("\(line): expected \(startsToEnds[lastStart]!) but found \(char). Score \(score)")
                    totalCorruptionScore += score
                    break
                }
            }
        }
    }
    return totalCorruptionScore
}

private func autocompleteScore(_ input: String) throws -> Int {
    let lines = input.split(separator: "\n")
    var allAutocompleteScores = [Int]()
    for line in lines {
        var stack = [Character]()

        var corrupted = false
        for char in line {
            if starts.contains(char) {
                stack.append(char)
            } else {
                assert(ends.contains(char))
                let lastStart = stack.popLast()!
                if startsToEnds[lastStart] != char {
                    // Corrupted! Skip!
                    corrupted = true
                    break
                }
            }
        }

        if corrupted {
            continue
        }

        var correction = [Character]()
        while !stack.isEmpty {
            let start = stack.popLast()!
            let end = startsToEnds[start]!
            correction.append(end)
        }

//        print("Incomplete:", line, "correction:", correction)

        var autocompleteScore = 0
        for char in correction {
            autocompleteScore *= 5
            autocompleteScore += completionScore[char]!
        }
        allAutocompleteScores.append(autocompleteScore)

//        print("Score", autocompleteScore)
    }

    return Int(allAutocompleteScores
        .median())
}

// MARK: Support code

let delimiters = Set([
    Pair<Character, Character>(left: "(", right: ")"),
    Pair(left: "[", right: "]"),
    Pair(left: "{", right: "}"),
    Pair(left: "<", right: ">"),
])
let starts = Set(delimiters.map(\.left))
let ends = Set(delimiters.map(\.right))
let startsToEnds = Dictionary(uniqueKeysWithValues: delimiters.map { ($0.left, $0.right) })
let endsToStarts = Dictionary(uniqueKeysWithValues: delimiters.map { ($0.right, $0.left) })

let corruptionScore: [Character: Int] = [
    ")": 3,
    "]": 57,
    "}": 1197,
    ">": 25137,
]

let completionScore: [Character: Int] = [
    ")": 1,
    "]": 2,
    "}": 3,
    ">": 4,
]
