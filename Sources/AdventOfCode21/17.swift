//
//  File.swift
//  
//
//  Created by Alejandro Martinez on 20/12/21.
//

import Foundation
import Parsing
import Algorithms

let day17 = Problem(
    day: 17,
    rawExample: "target area: x=20..30, y=-10..-5",
    parse: parse(_:),
    solve: findHighestY(_:), // 45  \   5778
    solve2: countValidInitialVelocities(_:) // 112  \   
)

typealias Area = (x: ClosedRange<Int>, y: ClosedRange<Int>)

private func parse(_ input: String) -> Area {
    let rangeParser = Int.parser()
        .skip("..")
        .take(Int.parser())
        .map { ClosedRange(uncheckedBounds: $0) }
    
    let parser = StartsWith<Substring>("target area: x=")
        .take(rangeParser)
        .skip(", y=")
        .take(rangeParser)
        .skipFinalLine()
    
    return parser.fullParse(input)!
}

// What is the highest y position it reaches on this trajectory?
private func findHighestY(_ target: Area) throws -> Int {
//    print(target)
    
    let xs = (1...target.x.upperBound)
    let ys = (1...max(abs(target.y.lowerBound), abs(target.y.upperBound)))
    let velocities = product(xs, ys).lazy.map(Point.init(x:y:))
    var highestYWithVelocity = (maxY: Int.min, initialVelocity: velocities.first!)
    
    for initialVelocity in velocities {
//        print("Testing velocity", initialVelocity)
        // Simulate probe at this velocity
        var probe = Probe(position: .zero, velocity: initialVelocity)
        var missedTarget = false
        var highestY = Int.min
        while !probe.position.intersects(target) {
            if probe.position.missedTarget(target) {
                missedTarget = true
                break
            }
            
            probe.runStep()
            highestY = max(highestY, probe.position.y)
//            print(probe)
        }
        
        // If the target was not missed it means this velocity was good
        if missedTarget {
//            print("Missed target")
            // Don't count the height, just go to next velocity
        } else {
            // Found the target with this initail velocity, record the max height that was reached
            if highestY > highestYWithVelocity.maxY {
                highestYWithVelocity = (highestY, initialVelocity)
            }
        }
    }
        
//    print(highestYWithVelocity)
    
    return highestYWithVelocity.maxY
}

// How many distinct initial velocity values cause the probe to be within the target area after any step?
private func countValidInitialVelocities(_ target: Area) throws -> Int {
//    print(target)
    
    let xs = (1...target.x.upperBound)
    let ys = (min(1, target.y.lowerBound)...max(abs(target.y.lowerBound), abs(target.y.upperBound)))
//    print("testing velocities", xs, ys)
    let velocities = product(xs, ys).lazy.map(Point.init(x:y:))
    var validVelocities = 0
    
    for initialVelocity in velocities {
        // Simulate probe at this velocity
        var probe = Probe(position: .zero, velocity: initialVelocity)
        var missedTarget = false
        while !probe.position.intersects(target) {
            if probe.position.missedTarget(target) {
                missedTarget = true
                break
            }
            
            probe.runStep()
//            print(probe)
        }
        
        // If the target was not missed it means this velocity was good
        if missedTarget {
//            print("Missed target")
            // Don't count the height, just go to next velocity
        } else {
            // Found the target with this initail velocity, count it!
            validVelocities += 1
            
//            allExampleValidInitialVelocities.remove(initialVelocity)
        }
    }
        
//    print(highestYWithVelocity)
//    print("pending velocities", allExampleValidInitialVelocities)
    return validVelocities
}

struct Probe {
    var position: Point
    var velocity: Point // vector
    
    mutating func runStep() {
        position.x += velocity.x
        position.y += velocity.y
        velocity.x = velocity.x.toZero
        velocity.y -= 1
    }
}

extension Int {
    var toZero: Int {
        if self == 0 {
            return self
        } else if self > 0 {
            return self - 1
        } else {
            return self + 1
        }
    }
}

extension Point {
    /// `true` if the point is in the bounds of the target area.
    func intersects(_ target: Area) -> Bool {
        let left = target.0.lowerBound
        let right = target.0.upperBound
        let top = target.1.upperBound
        let bottom = target.1.lowerBound
        
        if left <= x && x <= right && y <= top && bottom <= y {
            return true
        } else {
            return false
        }
    }
    
    /// `true` if the point is further to the right and down of the target area.
    func missedTarget(_ target: Area) -> Bool {
        let right = target.0.upperBound
        let bottom = target.1.lowerBound
        
        if right <= x || y <= bottom {
            return true
        } else {
            return false
        }
    }
}

/*
var allExampleValidInitialVelocities = Set([
    Point(x: 23, y: -10),
    Point(x: 25, y: -9),
    Point(x: 27, y: -5),
    Point(x: 29, y: -6),
    Point(x: 22, y: -6),
    Point(x: 21, y: -7),
    Point(x: 9, y: 0),
    Point(x: 27, y: -7),
    Point(x: 24, y: -5),
    Point(x: 25, y: -7),
    Point(x: 26, y: -6),
    Point(x: 25, y: -5),
    Point(x: 6, y: 8),
    Point(x: 11, y: -2),
    Point(x: 20, y: -5),
    Point(x: 29, y: -10),
    Point(x: 6, y: 3),
    Point(x: 28, y: -7),
    Point(x: 8, y: 0),
    Point(x: 30, y: -6),
    Point(x: 29, y: -8),
    Point(x: 20, y: -10),
    Point(x: 6, y: 7),
    Point(x: 6, y: 4),
    Point(x: 6, y: 1),
    Point(x: 14, y: -4),
    Point(x: 21, y: -6),
    Point(x: 26, y: -10),
    Point(x: 7, y: -1),
    Point(x: 7, y: 7),
    Point(x: 8, y: -1),
    Point(x: 21, y: -9),
    Point(x: 6, y: 2),
    Point(x: 20, y: -7),
    Point(x: 30, y: -10),
    Point(x: 14, y: -3),
    Point(x: 20, y: -8),
    Point(x: 13, y: -2),
    Point(x: 7, y: 3),
    Point(x: 28, y: -8),
    Point(x: 29, y: -9),
    Point(x: 15, y: -3),
    Point(x: 22, y: -5),
    Point(x: 26, y: -8),
    Point(x: 25, y: -8),
    Point(x: 25, y: -6),
    Point(x: 15, y: -4),
    Point(x: 9, y: -2),
    Point(x: 15, y: -2),
    Point(x: 12, y: -2),
    Point(x: 28, y: -9),
    Point(x: 12, y: -3),
    Point(x: 24, y: -6),
    Point(x: 23, y: -7),
    Point(x: 25, y: -10),
    Point(x: 7, y: 8),
    Point(x: 11, y: -3),
    Point(x: 26, y: -7),
    Point(x: 7, y: 1),
    Point(x: 23, y: -9),
    Point(x: 6, y: 0),
    Point(x: 22, y: -10),
    Point(x: 27, y: -6),
    Point(x: 8, y: 1),
    Point(x: 22, y: -8),
    Point(x: 13, y: -4),
    Point(x: 7, y: 6),
    Point(x: 28, y: -6),
    Point(x: 11, y: -4),
    Point(x: 12, y: -4),
    Point(x: 26, y: -9),
    Point(x: 7, y: 4),
    Point(x: 24, y: -10),
    Point(x: 23, y: -8),
    Point(x: 30, y: -8),
    Point(x: 7, y: 0),
    Point(x: 9, y: -1),
    Point(x: 10, y: -1),
    Point(x: 26, y: -5),
    Point(x: 22, y: -9),
    Point(x: 6, y: 5),
    Point(x: 7, y: 5),
    Point(x: 23, y: -6),
    Point(x: 28, y: -10),
    Point(x: 10, y: -2),
    Point(x: 11, y: -1),
    Point(x: 20, y: -9),
    Point(x: 14, y: -2),
    Point(x: 29, y: -7),
    Point(x: 13, y: -3),
    Point(x: 23, y: -5),
    Point(x: 24, y: -8),
    Point(x: 27, y: -9),
    Point(x: 30, y: -7),
    Point(x: 28, y: -5),
    Point(x: 21, y: -10),
    Point(x: 7, y: 9),
    Point(x: 6, y: 6),
    Point(x: 21, y: -5),
    Point(x: 27, y: -10),
    Point(x: 7, y: 2),
    Point(x: 30, y: -9),
    Point(x: 21, y: -8),
    Point(x: 22, y: -7),
    Point(x: 24, y: -9),
    Point(x: 20, y: -6),
    Point(x: 6, y: 9),
    Point(x: 29, y: -5),
    Point(x: 8, y: -2),
    Point(x: 27, y: -8),
    Point(x: 30, y: -5),
    Point(x: 24, y: -7),
])
*/
