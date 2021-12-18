import Algorithms
import Foundation
import Parsing

let day12 = Problem(
    day: 12,
    rawExample: """
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    """, // 10  /   35
//    rawExample: """
//    dc-end
//    HN-start
//    start-kj
//    dc-start
//    dc-HN
//    LN-dc
//    HN-end
//    kj-sa
//    kj-HN
//    kj-dc
//    """, // 19   / 103
//    rawExample: """
//    fs-end
//    he-DX
//    fs-he
//    start-DX
//    pj-DX
//    end-zg
//    zg-sl
//    zg-pj
//    pj-he
//    RW-he
//    fs-DX
//    pj-RW
//    zg-RW
//    start-pj
//    he-WI
//    zg-he
//    pj-fs
//    start-RW
//    """, // 226  /  3509
    parse: parseMap(_:),
    solve: countPaths(_:), // 4773
    solve2: countPaths2(_:) // 116985
)

typealias Connections = [String: [String]]
typealias Path = [String]
let start = "start"
let end = "end"

private func parseMap(_ input: String) -> Connections {
    let parsed = input
        .split(separator: "\n")
        .map { $0.split(separator: "-") }
        .map { (String($0[0]), String($0[1])) }

    var result = Connections()
    for (key, value) in parsed {
        result[key, default: []].append(value)
        result[value, default: []].append(key)
    }
    return result
}

// How many paths through this cave system are there that visit small caves at most once?
private func countPaths(_ input: Connections) throws -> Int {
    func findPaths(
        _ path: Path
    ) -> [Path] {
        let current = path.last!

        if current == end {
            return [path]
        }

        let exits = input[current]!

        var results = [Path]()
        for exit in exits where canVisit(exit, in: path) {
            let found = findPaths(path.appending(exit))
            results.append(contentsOf: found)
        }
        return results
    }

    let paths = findPaths([start])
//    print(paths)
//    print(paths.count)
    return paths.count
}

/// Can visit small caves only once
private func canVisit(_ exit: String, in path: Path) -> Bool {
    // If it's uppercase it can be visited as much as you want
    if exit.allSatisfy(\.isUppercase) {
        return true
    }
    // If it's ower case
    return !path.contains(exit)
}

// How many paths through this cave system are there that visit small caves at most once?
private func countPaths2(_ input: Connections) throws -> Int {
    func findPaths(
        _ path: Path
    ) -> [Path] {
        let current = path.last!

        if current == end {
            return [path]
        }

        let exits = input[current]!

        var results = [Path]()
        for exit in exits where canVisitExtraSmalLCave(exit, in: path) {
            let found = findPaths(path.appending(exit))
            results.append(contentsOf: found)
        }
        return results
    }

    let paths = findPaths([start])
//    print(paths)
//    print(paths.count)
    return paths.count
}

/// Can visit small caves only once, but one of them twice.
private func canVisitExtraSmalLCave(_ exit: String, in path: Path) -> Bool {
    // If it's uppercase it can be visited as much as you want
    if exit.isUppercase {
        return true
    }

    // If it's lower case...

    // If the exist has not been visited yet, go for it!
    if !path.contains(exit) {
        return true
    }

    // If it has been visited already...

    // If it's start or end we can just visit them once!
    if exit == start || exit == end {
        return false
    }

    // Check if we already visited a small cave twice
    let onlyLowercase = path.filter(\.isLowercase)
    if onlyLowercase.count != Array(onlyLowercase.uniqued()).count {
        return false
    }

    // We can visit again this small cave because is the first time we do this extra visit
    return true
}
