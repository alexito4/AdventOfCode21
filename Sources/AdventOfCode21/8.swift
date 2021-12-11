import Algorithms
import Foundation
import Parsing

let day8 = Problem(
    day: 8,
    rawExample: """
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    """,
    parse: parsePatternsAndOutputValues(_:),
    solve: countUniqueCountDigitsOnOutput(_:), // 26    |    548
    solve2: addAllOutputs(_:) // 61229    |
)

private func parsePatternsAndOutputValues(
    _ input: String
) -> [Entry] {
    let parseSegment =
        "a".map { "a" }
            .orElse("b".map { "b" })
            .orElse("c".map { "c" })
            .orElse("d".map { "d" })
            .orElse("e".map { "e" })
            .orElse("f".map { "f" })
            .orElse("g".map { "g" })

    let parseDigit = Many(parseSegment, atLeast: 1)
        .map { $0.joined() }
        .map { $0[...] }
        .map(Digit.init(string:))

    let parsePatterns = Many(
        parseDigit,
        separator: " "
    )

    let parseEntry = parsePatterns
        .skip(" | ")
        .take(parsePatterns)

    let parseEntries = Many(
        parseEntry,
        separator: "\n"
    )
    .skip(Rest())

    let parser = parseEntries

    let result = parser.fullParse(input)!
//    assert(result.0.count == 10)
//    assert(result.1.count == 4)
    return result
}

// In the output values, how many times do digits 1, 4, 7, or 8 appear?
private func countUniqueCountDigitsOnOutput(_ entries: [Entry]) throws -> Int {
    let uniquesCount = digitsWithUniqueCount.map(\.set.count)
    var uniques = 0
    for entry in entries {
        for digit in entry.digits {
            if uniquesCount.contains(digit.set.count) {
                uniques += 1
            }
        }
    }
    return uniques
}

// What do you get if you add up all of the output values?
private func addAllOutputs(_ entries: [Entry]) throws -> Int {
//    let entries = parsePatternsAndOutputValues("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")

    // autmate finding rules
//    print(countsToDigits)
    var rules = [Character: [Int: Int]]()
    for segment in allSegments.string {
        // bucked count -> how many times is in it
        var segmentRules = [Int: Int]()
        for bucket in countsToDigits.keys {
            for digit in countsToDigits[bucket]! {
                if digit.set.contains(segment) {
                    segmentRules[bucket, default: 0] += 1
                }
            }
        }
        rules[segment] = segmentRules
    }
//    print(rules)

    var sum = 0
    for entry in entries {
        // Make count buckets for this entry
        let entryCountsToDigits: [Int: [Digit]] = {
            var result = [Int: [Digit]]()
            for digit in entry.patterns {
                result[digit.set.count, default: []].append(digit)
            }
            return result
        }()
//        print(entryCountsToDigits)

        // Make rules for this entry
        var entryRules = [Character: [Int: Int]]()
        for segment in allSegments.string {
            // bucked count -> how many times is in it
            var segmentRules = [Int: Int]()
            for bucket in entryCountsToDigits.keys {
                for digit in entryCountsToDigits[bucket]! {
                    if digit.set.contains(segment) {
                        segmentRules[bucket, default: 0] += 1
                    }
                }
            }
            entryRules[segment] = segmentRules
        }

        func matchingRules(_ l: [Int: Int], _ r: [Int: Int]) -> Bool {
            guard l.count == r.count else { return false }
            for (bucket, count) in l {
                if r[bucket, default: 0] == count {
                    continue
                } else {
                    return false
                }
            }
            return true
        }

        var realToMixed = [Character: Character]()
        var mixedToReal = [Character: Character]()
        // take a rule for the entry
        // go trough all oficial rules, checking every rule against the entry rule
        // whatever rule matches, it means the segment from the entry rule is that segment in this entry
        for (entrySegment, entryRule) in entryRules {
            for (candidate, rule) in rules {
                if matchingRules(entryRule, rule) {
                    if realToMixed[candidate] != nil {
                        print("ambiguous")
                        assertionFailure()
                    }
                    // CAREFUL WITH THIS ORDER. REVERSES THE MEANING OF THE SOLUTION.
                    realToMixed[candidate] = entrySegment // Real -> Fake
                    mixedToReal[entrySegment] = candidate // Fake -> Real
                }
            }
        }

        print(String(allSegments.makeDrawable().map { realToMixed[$0] ?? $0 }))
//        print(solution.sorted(by: binaryCompare(\.key, by: <)))

//        print("Patterns:")
//        for digit in entry.patterns {
//            // Rewire
//            let rewired = Digit(String(digit.string.map { mixedToReal[$0]! }))
//            let number = reversedDigits[rewired]!
//            print("\(digit.string): \(number)")
//        }

//        print("Output:")
        var numberString = ""
        for digit in entry.digits {
            // Rewire
            let rewired = Digit(String(digit.string.map { mixedToReal[$0]! }))
            let number = reversedDigits[rewired]!
//            print("\(digit.string): \(number)")
            numberString.append(String(number))
        }

        let entryOutput = Int(numberString)!
        sum += entryOutput
    }

    return sum
}

// MARK: Support code

typealias Segment = Character
struct Digit: Hashable {
    var string: String
    var set: Set<Character>

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.set == rhs.set
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(set)
    }
}

typealias Entry = (patterns: [Digit], digits: [Digit])

let allSegments = Digit(string: "abcdefg")
let digits = [
    0: Digit("abcefg"), // 6
    1: Digit("cf"), // 2 unique
    2: Digit("acdeg"), // 5
    3: Digit("acdfg"), // 5
    4: Digit("bcdf"), // 4 unique
    5: Digit("abdfg"), // 5
    6: Digit("abdefg"), // 6
    7: Digit("acf"), // 3 unique
    8: Digit("abcdefg"), // 7 unique
    9: Digit("abcdfg"), // 6
]
// Digit -> Int
let reversedDigits = Dictionary(uniqueKeysWithValues: digits.map { ($1, $0) })
// [count of X: [digit, digit...]
let countsToDigits: [Int: [Digit]] = {
    var result = [Int: [Digit]]()
    for digit in digits.values {
        result[digit.set.count, default: []].append(digit)
    }
    return result
}()

let digitsWithUniqueCount = countsToDigits.values.filter { $0.count == 1 }.flatMap { $0 }

extension Digit {
    init(_ string: String) {
        self.init(string: String(string), set: .init(string))
    }

    init(string: Substring) {
        self.init(string: String(string), set: .init(string))
    }

    func debug() {
        print(set.sorted().map(String.init).joined())
    }

    func makeDrawable() -> String {
        let a = set.contains("a") ? "aaaa" : "...."
        let b = set.contains("b") ? "b" : "."
        let c = set.contains("c") ? "c" : "."
        let d = set.contains("d") ? "dddd" : "...."
        let e = set.contains("e") ? "e" : "."
        let f = set.contains("f") ? "f" : "."
        let g = set.contains("g") ? "gggg" : "...."
        return """
         \(a)
        \(b)    \(c)
        \(b)    \(c)
         \(d)
        \(e)    \(f)
        \(e)    \(f)
         \(g)
        """
    }

    func draw() {
        print("""
        \(reversedDigits[self]!):
        \(makeDrawable())
        """)
    }
}

private func printDigits() {
    for element in digits.sorted(by: { $0.key < $1.key }) {
        element.value.draw()
    }
}
