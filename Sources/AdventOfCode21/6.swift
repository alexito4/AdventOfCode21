import Foundation
import Overture
import Parsing
let day6 = Problem(
    day: 6,
    rawExample: "3,4,3,1,2",
    parse: parseLanternfishAges(_:),
    solve: flip(curry(calculate))(80), // 18: 26, 80: 5934 |    360610
    solve2: flip(curry(calculate))(256)
)

private func parseLanternfishAges(_ input: String) -> [Int] {
    let parser = Many(Int.parser(), separator: ",").skip(Rest())
    return parser.fullParse(input)!
}

func calculate(_ lanternfish: [Int], for maxDays: Int) -> Int {
    var alive = lanternfish.reduce(into: [Int: Int]()) { dict, number in
        dict[number, default: 0] += 1
    }
    // Fill all for better display
    for i in 0..<spawnEveryDays + extraDays {
        if alive[i] == nil {
            alive[i] = 0
        }
    }
    func aliveString() -> String {
        alive
            .sorted(by: binaryCompare(\.key, by: <))
            .enumerated()
            .map {
                if $0 == 6 {
                    return "[\($1.key): \($1.value)]"
                } else {
                    return "(\($1.key): \($1.value))"
                }
            }
            .joined(separator: "  ")
    }
//    print("Initial state:", aliveString())
    for _ in 1...maxDays {
        var new = Dictionary(uniqueKeysWithValues: alive.map { time, amount in
            (time - 1, amount)
        })

        // The ones at -1 were the ones at 0.
        if let needRefresh = new[-1] {
            // Refresh their timer:
            new[spawnEveryDays - 1, default: 0] += needRefresh
            new[-1] = nil
            // Spawn more
            new[spawnEveryDays + extraDays - 1] = needRefresh
        }

        alive = new
//        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(aliveString())")
    }
    let count = alive.values.sum()
//    print(count)
    return count
}

// Try to simulate all the population individually day by day.
// This grows exponentially and after ~100 iterations it takes too much time.
// The benchmarks below was an exploration to see how much faster could be made,
// and to play with the benchmarks package ^^
func simulate(_ lanternfish: [Int], for maxDays: Int) -> Int {
//    let maxDays = 18
    var alive = lanternfish
//    print("Initial state:", alive.map(String.init).joined(separator: ","))
    for _ in 1...maxDays {
        for i in alive.indices {
            let fish = alive[i]
            let (timer, spawn) = simulateDay(for: fish)
            alive[i] = timer
            if let spawn = spawn {
                alive.append(spawn)
            }
        }
//        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
    }
//    print(alive.count)
    return alive.count
}

let spawnEveryDays = 7
let extraDays = 2
/// - Each lanternfish creates a new lanternfish once every 7 days
/// - New lanternfish: two more days for its first cycle.
///
/// - A lanternfish that creates a new fish resets its timer to 6, not 7 (because 0 is included as a valid timer value).
/// - The new lanternfish starts with an internal timer of 8 and does not start counting down until the next day.
typealias DayOutput = (timer: Int, spawn: Int?)
private func simulateDay(for fish: Int) -> DayOutput {
    if fish == 0 {
        return (spawnEveryDays - 1, spawnEveryDays - 1 + extraDays)
    } else {
        return (fish - 1, nil)
    }
}

// MARK: - Benchmark

// Trying to make a pure simulation of every day be fast...

// private func simulateInline(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
////    print("Initial state:", alive.map(String.init).joined(separator: ","))
//    for _ in 1...maxDays {
//        for i in alive.indices {
//            let fish = alive[i]
//            if fish == 0 {
//                let newDays = spawnEveryDays - 1
//                alive[i] = newDays
//                alive.append(newDays + extraDays)
//            } else {
//                alive[i] = fish - 1
//            }
//        }
////        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
//    }
////    print(alive.count)
//    return alive.count
// }
//
// func simulateInout(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
////    print("Initial state:", alive.map(String.init).joined(separator: ","))
//    for _ in 1...maxDays {
//        for i in alive.indices {
//            if let spawn = simulateDayInout(for: &alive[i]) {
//                alive.append(spawn)
//            }
//        }
////        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
//    }
////    print(alive.count)
//    return alive.count
// }
//
// func simulateDayInout(for fish: inout Int) -> Int? {
//    if fish == 0 {
//        fish = spawnEveryDays - 1
//        return spawnEveryDays - 1 + extraDays
//    } else {
//        fish = fish - 1
//        return nil
//    }
// }
//
// func simulateUnsafe(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
//    for _ in 1...maxDays {
//        var copy = alive
//        let result: Void? = alive.withContiguousMutableStorageIfAvailable { buffer -> Void in
////            var toSpawn = Array<Int>()
////            toSpawn.reserveCapacity(buffer.count)
//
//            for i in buffer.indices {
//                let fish = buffer[i]
//                let (timer, spawn) = simulateDay(for: fish)
//                buffer[i] = timer
//                if let spawn = spawn {
//                    copy.append(spawn)
//                }
//            }
//
////            return toSpawn
//        }
//        alive.append(contentsOf: copy[alive.endIndex...])
//        if let toSpawn = result {
////            alive.append(contentsOf: toSpawn)
//        } else {
//            assertionFailure("withContiguousMutableStorageIfAvailable didn't run")
//        }
//    }
//    return alive.count
// }
//
// func simulateOneRef(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
//    var indices = alive.indices
////    print("Initial state:", alive.map(String.init).joined(separator: ","))
//    for _ in 1...maxDays {
//        for i in indices {
//            let fish = alive[i]
//            let (timer, spawn) = simulateDay(for: fish)
//            alive[i] = timer
//            if let spawn = spawn {
//                alive.append(spawn)
//            }
//        }
//        indices = alive.indices
////        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
//    }
////    print(alive.count)
//    return alive.count
// }
//
// private func simulateGCD(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
////    print("Initial state:", alive.map(String.init).joined(separator: ","))
//    for _ in 1...maxDays {
//        let queue = DispatchQueue(label: "my serial", qos: .userInteractive, target: DispatchQueue.global(qos: .userInteractive))
//        DispatchQueue.concurrentPerform(iterations: alive.count) { i in
//            let sem = DispatchSemaphore(value: 0)
////            print(i, "start")
//            queue.async {
////                print(i, "get fish")
//                let fish = alive[i]
//                DispatchQueue.global(qos: .userInteractive).async {
////                    print(i, "simulate")
//                    let (timer, spawn) = simulateDay(for: fish)
//                    queue.async {
////                        print(i, "result")
//                        alive[i] = timer
//                        if let spawn = spawn {
//                            alive.append(spawn)
//                        }
//                        sem.signal()
//                    }
//                }
//            }
////            print(i, "waiting")
//            sem.wait()
////            print(i, "done")
//        }
////        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
//    }
////    print(alive.count)
//    return alive.count
// }
//
// private func simulateConcurrency(_ lanternfish: [Int], for maxDays: Int) -> Int {
////    let maxDays = 18
//    var alive = lanternfish
////    print("Initial state:", alive.map(String.init).joined(separator: ","))
//    for _ in 1...maxDays {
//
//        Task.unsafeAwaiting {
//            await withTaskGroup(of: (DayOutput, Int).self, returning: Void.self) { group in
//                for i in alive.indices {
//                    let fish = alive[i]
//
//                    group.addTask {
//                        (simulateDay(for: fish), i)
//                    }
//                }
//                for await it in group {
//                    let ((timer, spawn), i) = it
//                    alive[i] = timer
//                    if let spawn = spawn {
//                        alive.append(spawn)
//                    }
//                }
//            }
//        }
//
////        print("After \("\(day)".leftPadding(to: 2)) day\(day > 1 ? "s" : " "): \(alive.map(String.init).joined(separator: ","))")
//    }
////    print(alive.count)
//    return alive.count
// }

import struct CollectionsBenchmark.Benchmark

func day6Benchmark() {
    var benchmark = Benchmark(title: "Simulate Lanternfish")

    let fish = [3, 4, 3, 1, 2] // try! day6.part1.parse(readFile(day: "6"))

    benchmark.addSimple(
        title: "Simulation",
        input: Int.self
    ) { input in
        _ = simulate(fish, for: input)
    }

    benchmark.addSimple(
        title: "Calculation",
        input: Int.self
    ) { input in
        _ = calculate(fish, for: input)
    }
//
//    benchmark.addSimple(
//        title: "Inline manual",
//        input: Int.self
//    ) { input in
//        _ = simulateInline(fish, for: input)
//    }
//
//    benchmark.addSimple(
//        title: "Inout",
//        input: Int.self
//    ) { input in
//        _ = simulateInout(fish, for: input)
//    }
//
//    benchmark.addSimple(
//        title: "Unsafe",
//        input: Int.self
//    ) { input in
//        _ = simulateUnsafe(fish, for: input)
//    }
//
//    benchmark.addSimple(
//      title: "One Ref",
//      input: Int.self
//    ) { input in
//        _ = simulateOneRef(fish, for: input)
//    }
//
//    benchmark.addSimple(
//      title: "GCD",
//      input: Int.self
//    ) { input in
//        _ = simulateGCD(fish, for: input)
//    }

//    benchmark.addSimple(
//      title: "Concurrency",
//      input: Int.self
//    ) { input in
//        _ = simulateConcurrency(fish, for: input)
//    }

    benchmark.main()
}
