import Foundation

let day14 = Problem(
    day: 14,
    rawExample: """

    """,
    parse: parse(_:),
    solve: calculate1(_:),
    solve2: notYet(_:)
)

struct PolymerInstructions {
    let template: String
    let insertionRules: [Rule]

    struct Rule {
        let match: String
        let insert: String
    }
}

private func parse(_ input: String) -> PolymerInstructions {
    fatalError()
}

// What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
private func calculate1(_ input: PolymerInstructions) throws -> Int {
    try notYet(input)
}
