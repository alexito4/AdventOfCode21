import BitArrayModule
import Collections
import Foundation

let day3 = Problem(
    day: 3,
    example: """
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    """,
    solve: calculatePowerConsumption, // 198    /      3847100
    solve2: calculateLifeSupportRating // 230   /     4105235
)

func calculateLifeSupportRating(_ input: String) -> Int {
    let numbers = input
        .split(separator: "\n")
        .map { BitArray($0.map { Int(String($0))!.let(Bool.init(zeroOrOne:)) }) }

    let oxygen = calculateOxygen(numbers)
    let co2 = calculateCO2(numbers)
    return oxygen * co2
}

private func calculateOxygen(_ numbers: [BitArray]) -> Int {
    var kept = numbers.map(Optional.some)
    for columnIndex in numbers[0].indices { // for each column
        // Find most common number on the current column of the still kept rows
        var counts = (zeros: 0, ones: 0)
        for number in kept {
            if number![columnIndex] {
                counts.ones += 1
            } else {
                counts.zeros += 1
            }
        }
        let mostCommon = with(counts) { $0.ones >= $0.zeros ? 1 : 0 }
            .let(Bool.init(zeroOrOne:))

        // Discard the numbers that don't have the same bit on this column
        for j in kept.indices {
            guard kept[j] != nil else { continue }

            if mostCommon != kept[j]![columnIndex] {
                kept[j] = nil
            }
        }
        kept = kept.filter { $0 != nil }
        if kept.count == 1 {
            break
        }
    }
    assert(kept.count == 1)
    return kept[0]!.decimalRepresentation
}

private func calculateCO2(_ numbers: [BitArray]) -> Int {
    var kept = numbers.map(Optional.some)
    for columnIndex in numbers[0].indices { // for each column
        // Find least common number on the current column of the still kept rows
        var counts = (zeros: 0, ones: 0)
        for number in kept {
            if number![columnIndex] {
                counts.ones += 1
            } else {
                counts.zeros += 1
            }
        }
        let leastCommon = with(counts) { $0.zeros <= $0.ones ? 0 : 1 }
            .let(Bool.init(zeroOrOne:))

        // Discard the numbers that don't have the same bit on this column
        for j in kept.indices {
            guard kept[j] != nil else { continue }

            if leastCommon != kept[j]![columnIndex] {
                kept[j] = nil
            }
        }
        kept = kept.filter { $0 != nil }

        if kept.count == 1 {
            break
        }
    }
    assert(kept.count == 1)
    return kept[0]!.decimalRepresentation
}

func calculatePowerConsumption(_ input: String) -> Int {
    let numbers = input
        .split(separator: "\n")
        .map { BitArray($0.map { Int(String($0))!.let(Bool.init(zeroOrOne:)) }) }

    var columns = Array(repeating: (zeros: 0, ones: 0), count: numbers[0].count)

    for column in numbers[0].indices {
        for number in numbers {
            var counts = columns[column]
            if number[column] {
                counts.ones += 1
            } else {
                counts.zeros += 1
            }
            columns[column] = counts
        }
    }

    // if gamma ist most common and epsilon is less commo, and we just have a binary number,
    // epsiol is just the inverse of gamma.
    // if this were bits we could invert them but how to do it properly escapes me right now
    // so lets just do it with arrays.

    let gammaBits = columns
        .map { $0.zeros > $0.ones ? 0 : 1 }

    let gamma = Int(gammaBits.map(String.init).joined(), radix: 2)!

    let epsilonBits = gammaBits.map { $0 == 1 ? 0 : 1 }
    let epsilon = Int(epsilonBits.map(String.init).joined(), radix: 2)!

    return gamma * epsilon
}
