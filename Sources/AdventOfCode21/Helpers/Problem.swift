struct ProblemPart<Input, Output>: Hashable {
    var day: Int
    var part: Int

    var example: Input
    var parse: (String) -> Input

    var solve: (Input) throws -> Output

    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(part)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.day == rhs.day && lhs.day == rhs.day
    }
}

struct Problem<Input, Output>: Hashable {
    var part1: ProblemPart<Input, Output>
    var part2: ProblemPart<Input, Output>

    init(
        day: Int,
        example: Input,
        parse: @escaping (String) -> Input,
        solve: @escaping (Input) throws -> Output,
        solve2: @escaping (Input) throws -> Output
    ) {
        part1 = .init(day: day, part: 1, example: example, parse: parse, solve: solve)
        part2 = .init(day: day, part: 2, example: example, parse: parse, solve: solve2)
    }

    init(
        day: Int,
        rawExample: String,
        parse: @escaping (String) -> Input,
        solve: @escaping (Input) throws -> Output,
        solve2: @escaping (Input) throws -> Output
    ) {
        let parsedExample = parse(rawExample)
        self.init(day: day, example: parsedExample, parse: parse, solve: solve, solve2: solve2)
    }
}

extension Problem where Input == String {
    init(
        day: Int,
        example: Input,
        solve: @escaping (Input) throws -> Output,
        solve2: @escaping (Input) throws -> Output
    ) {
        part1 = .init(day: day, part: 1, example: example, parse: { $0 }, solve: solve)
        part2 = .init(day: day, part: 2, example: example, parse: { $0 }, solve: solve2)
    }
}

enum ProblemData {
    case example
    case real
}

import Then
extension Problem: Then {}

struct NoFileError: Error {}

struct Unimplemented: Error {}
func notYet<I, O>(_ i: I) throws -> O {
    throw Unimplemented()
}

import Algorithms
import Foundation

func readFile(day: String) throws -> String {
    let fileName = day
    guard let file = Bundle.myModule.url(forResource: fileName, withExtension: "txt") else {
        throw NoFileError()
    }
    let data = try! Data(contentsOf: file)
    let contents = String(data: data, encoding: .utf8)!
    return contents
}

func run<I, O>(
    _ problem: ProblemPart<I, O>, _ d: ProblemData
) throws -> O {
    let input: I
    switch d {
    case .example:
        input = problem.example
    case .real:
        let contents = try readFile(day: "\(problem.day)")
        input = problem.parse(contents)
    }
//    print("Day \(problem.day) Part \(problem.part): \(problem.solve(input))")
    return try problem.solve(input)
}

func _run<I, O>(
    _ part: ProblemPart<I, O>,
    _ d: ProblemData
) throws {
    let output = try run(part, d)
    print("Day \(part.day) - Part \(part.part) - \(d)")
    print("==>", output)
}

func run<I, O>(_ problem: Problem<I, O>) throws {
    try _run(problem.part1, .example)
    try _run(problem.part1, .real)
    try _run(problem.part2, .example)
    try _run(problem.part2, .real)
}
