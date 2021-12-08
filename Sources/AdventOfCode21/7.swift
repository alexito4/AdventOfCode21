import Algorithms
import Foundation
import Parsing

let day7 = Problem(
    day: 7,
    rawExample: "16,1,2,0,4,2,7,1,2,14",
    parse: parseCrabsPositions(_:),
    solve: calculateLeastFuelToAlign(_:), // pos 2, fuel 37             |  fuel 341558
    solve2: calculateLeastFuelToAlignNotConstant(_:) // pos 5, fuel 168 |  pos 484 fuel 93214037
)

private func parseCrabsPositions(_ input: String) -> [Int] {
    let parser = Many(Int.parser(), separator: ",").skip(Rest())
    return parser.fullParse(input)!
}

private func calculateLeastFuelToAlign(_ positions: [Int]) -> Int {
    let target = Int(positions.median())
//    print("target", target)
    let totalCost = positions.reduce(into: 0) { total, pos in
        let thisCost = abs(pos - target)
//        print("Move from \(pos) to \(target) costs \(thisCost)")
        total += thisCost
    }
//    print(totalCost)
    return totalCost
}

private func calculateLeastFuelToAlignNotConstant(_ positions: [Int]) throws -> Int {
    // I'm missing something because when getting the average and rounding sometimes it needs to go up sometimes down.
    // I'm not sure what's the math reason behind it so... let's just try both?
    let double = positions.average()
    let targetUp = Int(double.rounded(.up))
    let targetDown = Int(double.rounded(.down))
    if targetUp == targetDown {
        return cost(positions, target: targetUp)
    } else {
        let costUp = cost(positions, target: targetUp)
        let costDown = cost(positions, target: targetDown)
        return min(costUp, costDown)
    }
}

private func calculateLeastFuelToAlignNotConstant_BRUTE(_ positions: [Int]) throws -> Int {
    // BRUTE FORCE
    var least = (target: Int.max, cost: Int.max)
    let (min, max) = positions.minAndMax()!
    for target in min...max {
        let totalCost = cost(positions, target: target)
//        print("Cost for \(target): \(totalCost)")
        if totalCost < least.cost {
            least = (target, totalCost)
        }
    }
//    print("Least: \(least)")
    return least.cost
}

private func cost(_ positions: [Int], target: Int) -> Int {
    positions.reduce(into: 0) { total, pos in
        let movements = abs(pos - target)
        let thisCost = Int.summation(upTo: movements)
//        print("Move from \(pos) to \(target) needs \(thisCost) movements that cost \(thisCost)")
        total += thisCost
    }
}

extension Int {
    static func summation(upTo n: Int) -> Int {
        n * (n + 1) / 2
    }
}
