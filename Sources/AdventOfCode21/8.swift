import Foundation
import Parsing
import Algorithms

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
    solve2: addAllOutputs(_:)
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
    let uniquesCount = digitsWithUniqueCount.map { $0.set.count }
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
    let entries = parsePatternsAndOutputValues("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")

    let allPossible = allSegments.string.reduce(into: [Character:Set<Character>]()) { dict, c in
        dict[c] = allSegments.set
    }

    for entry in entries {
        var possible = allPossible
        
        let patternAndItsCandidates = entry.patterns
            .filter { $0.set.count != 7 } // doesn't give us any useful info
            .map { ($0.string, countsToDigits[$0.set.count]!.map(\.string)) }
            .sorted(by: binaryCompare(\.1.count, by: <))
        let partitionedPatternAndItsCandidates = patternAndItsCandidates
            .chunked(by: binaryCompare(\.1.count, by: ==))
            .map { $0.sorted(by: binaryCompare(\.0.count, by: <)) }
        print(partitionedPatternAndItsCandidates)
//        print(patternAndItsCandidates.map(String.init(describing:)).joined(separator: "\n"))
        
        let patternAndItsCandidates_Unique = partitionedPatternAndItsCandidates[0]
        let patternAndItsCandidates_Multiple = partitionedPatternAndItsCandidates[1]

        for (pattern, c) in patternAndItsCandidates_Unique {
            
        }
        
        for pattern in entry.patterns.sorted(by: binaryCompare(\.set.count, by: <)) {
//            guard countsToDigits[pattern.set.count]!.count == 1  else { continue }
//            print("pattern \(pattern.string) -> \(countsToDigits[pattern.set.count]!)")
            // Find the digits that have the same count, for those take their segments.
            // Now you have all the segments taht could correspond to this pattern.
            let segmentsWithThisCount = countsToDigits[pattern.set.count]!
                .reduce(into: Set<Character>()) { set, digit in
                    set.formUnion(digit.set)
                }
            
            print(pattern.string, segmentsWithThisCount.sorted(by: binaryCompare(\.self, by: <)))
//            // test
//            if segmentsWithThisCount.count < 7 {
//                print("")
//            }

            // Go trough all those segments and remove all other possibilities
            for segment in segmentsWithThisCount {
                possible[segment]! = pattern.set  // TODO: OR THIS IS BROKEN, OR WE SHOULD JUST CHECK FOR UNIQUE PATTERNS.
                // just doing the uniques makes it work better but still not correct.
                // is like the search space needs more constraints.
            }
        }
        print(possible)
        // Now that we have all obvious wrong candidates removed,
        // let's try to clean it up with a backtracking recursive algorithm.
        let sorted = possible.sorted(by: binaryCompare(\.value.count, by: <))
//        let sorted = possible.sorted(by: binaryCompare(\.key, by: <))
        print(sorted)
        let result = cleanup(sorted.map { $0 })
            .sorted(by: binaryCompare(\.0, by: <))
        print(result)
        let dict = Dictionary(uniqueKeysWithValues: result)
        print(String(allSegments.makeDrawable().map { dict[$0].map { $0.first! } ?? $0 }))
        // Make sure the backtracking found a correct solution.
        assert(result.allSatisfy({ $0.1.count == 1 }))
    }
    
    
    return try notYet(entries)
}

private func cleanup(
    _ possible: [(segment: Character, characters: Set<Character>)],
    segmentIndex: Int = 0 // index of the array to try
) -> [(Character, Set<Character>)] {
    // Go to the current segment index we're investigating
    // - If it has 1 option this segment is correct! Go to the next one
    if possible[segmentIndex].characters.count == 1 {
        let nextSegmentIndex = possible.index(after: segmentIndex)
        
        // Since there is only 1, this segment is fixed. Remove it from the next ones...
        let candidate = possible[segmentIndex].characters.first!
        var copy = possible
        for i in nextSegmentIndex..<copy.endIndex {
            copy[i].characters.remove(candidate)
        }
        
        // If there is no next one, good we're done!
        if nextSegmentIndex == possible.endIndex {
            // END CONDITION!
            return copy
        } else {
            // If there is a next one, recurse with that index
            return cleanup(copy, segmentIndex: nextSegmentIndex)
        }
    } else { // - If it still has multiple options...
        // We need to try each candidate for the rest of the array
        for candidate in possible[segmentIndex].characters {
            var copy = possible
            // Fix this candidate
            copy[segmentIndex].characters = [candidate]
            // No need to remove it now since the next recursion is gonna do it
//             And remove it from the rest of segments
//            for i in (segmentIndex+1)..<copy.endIndex {
//                copy[i].characters.remove(candidate)
//            }
//            print("candidate \(candidate) for \(copy[segmentIndex].segment)")
//            print(copy)
            // With this new "copy" that has the candidate "fixed" we can try to continue
            let result = cleanup(copy, segmentIndex: segmentIndex)
            // Check if the result is valid by having only 1 character...
            if result[segmentIndex...].allSatisfy({ $0.1.count == 1 }) {
                // SUCCESS!
                return result
            } else {
                // If some other segments came back with multiple candidates, try the next one
                continue
            }
        }
        // if the for ended without returning a success it means we don't have enough correct candidates.
        // so we need to backtrack
        return possible
    }
}

// MARK: Support code

typealias Segment = Character
struct Digit: Hashable {
    var string: String
    var set: Set<Character>
}
typealias Entry = (patterns: [Digit], digits: [Digit])

let allSegments = Digit(string: "abcdefg")
let digits = [
    0: Digit("abcefg"), // 6
    1: Digit("cf"),     // 2 unique
    2: Digit("acdeg"),  // 5
    3: Digit("acdfg"),  // 5
    4: Digit("bcdf"),   // 4 unique
    5: Digit("abdfg"),  // 5
    6: Digit("abdefg"), // 6
    7: Digit("acf"),    // 3 unique
    8: Digit("abcdefg"),// 7 unique
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
        print(self.set.sorted().map(String.init).joined())
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
        \(self.makeDrawable())
        """)
    }
}
private func printDigits() {
    for element in digits.sorted(by: { $0.key < $1.key }) {
        element.value.draw()
    }
}
