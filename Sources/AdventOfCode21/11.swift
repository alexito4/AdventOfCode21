//
//  File.swift
//  
//
//  Created by Alejandro Martinez on 11/12/21.
//

import Foundation
import Parsing

let day11 = Problem(
    day: 11,
    rawExample: """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """,
    parse: parseOctopuses(_:),
    solve: calculateTotalFlashes(_:), // 1656    |     1667
    solve2: firstSyncFlash(_:)          // 195          |  488
)

private func parseOctopuses(_ input: String) -> Map2d {
    let parseDigit = First<Substring>()
        .map(String.init).map { $0[...] }
        .pipe(Int.parser())

    let parseLine = Many(parseDigit, atLeast: 1)

    let parser = Many(
        parseLine,
        atLeast: 1,
        separator: "\n"
    )
    .endLine()
    return parser.fullParse(input)!
}

// How many total flashes are there after 100 steps?
private func calculateTotalFlashes(_ map: Map2d) throws -> Int {
    let steps = 100
    var map = map //parseOctopuses("""
//   11111
//   19991
//   19191
//   19991
//   11111
//   """)
//    map.draw().debug()
//    print("---")

    var totalFlashes = 0
    for _ in (1...steps) {
        // Sum flashes
        totalFlashes +=  map.simulateStep()
//        print("After step \(step)")
//        map.draw().debug()
//        print("---")
    }
//    map.draw().debug()
//    print("flashed", totalFlashes)
    return totalFlashes
}

// What is the first step during which all octopuses flash?
private func firstSyncFlash(_ map: Map2d) throws -> Int {
    var map = map
    var step = 0
    while !map.allFlashed() {
        step += 1
        _ = map.simulateStep()
    }
    return step
}

// MARK: Support code

private extension Map2d {
    mutating func simulateStep() -> Int {
        var flashed = Set<Point>()
        for point in self.points() {
            self.increaseEnergy(point, &flashed)
        }
        // Reset map
        flashed.forEach {
            self[$0] = 0
        }
        
        return flashed.count
    }
    
    mutating func increaseEnergy(_ point: Point, _ alreadyFlashed: inout Set<Point>) {
        self[point] += 1

        if self[point] > 9 && !alreadyFlashed.contains(point) {
            alreadyFlashed.insert(point)
            
            for adj in adjecentPointsOf(x: point.x, y: point.y) {
                increaseEnergy(adj, &alreadyFlashed)
            }
        }
    }
    
    func allFlashed() -> Bool {
        self.allElements().allSatisfy { $0 == 0 }
    }
}
