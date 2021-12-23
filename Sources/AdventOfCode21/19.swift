import Algorithms
import Foundation
import Parsing

let day19 = Problem(
    day: 19,
    rawExample: """
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
    """,
    parse: parse(_:),
    solve: countBeacons(_:),
    solve2: largestScannerDistance(_:)
)

private func parse(_ input: String) -> Reports {
    let pointParser = Int.parser()
        .skip(",")
        .take(Int.parser())
        .skip(",")
        .take(Int.parser())
        .map { Point3(x: $0, y: $1, z: $2) }

    let reportParser = "--- scanner "
        .take(Int.parser())
        .skip(" ---\n")
        .take(Many(pointParser, separator: "\n"))
        .map { Scanner(number: $0, beacons: $1) }

    let parser = Many(reportParser, separator: Whitespace().pullback(\.utf8))
        .skipFinalLine()
    return parser.fullParse(input)!
}

// How many beacons are there?
private func countBeacons(_ input: Reports) throws -> Int {
    let detectedScanners = detectScanners(input)

    let foundBeacons = detectedScanners.reduce(into: Set<Point3>()) { acc, scanner in
        acc.formUnion(scanner.beacons)
    }

    return foundBeacons.count
}

// What is the largest Manhattan distance between any two scanners?
private func largestScannerDistance(_ input: Reports) throws -> Int {
    var gatheredCenters = [(Int, Point3)]()
    _ = detectScanners(input, gatherCenter: {
        gatheredCenters.append(($0.number, $1))
    })
//    print("Gathered:", gatheredCenters.sorted(by: binaryCompare(\.0, by: <)))

    let maxDistance = gatheredCenters
        .combinations(ofCount: 2)
        .map { ($0[0].0, $0[1].0, $0[0].1.distance(to: $0[1].1)) }
        .debug()
        .max(by: binaryCompare(\.2.magnitude, by: <))!

//    print("Gathered", maxDistance)

    return maxDistance.2.magnitude
}

// Returns all detected scanners with coordinates based on the first scanner
private func detectScanners(_ input: Reports, gatherCenter: (Scanner, Point3) -> Void = { _, _ in }) -> [Scanner] {
    var currentScanner = input[0]

    var detectedScanners = [Scanner]()
    detectedScanners.append(currentScanner)

    // The scanners and beacons map a single contiguous 3d region.
    // So keep going until we detected all scanners
    while detectedScanners.count != input.count {
        print("\nCurrent:", currentScanner.number)

        let otherScanners = input
            .filter { $0.number != currentScanner.number } // don't match against itself
        print("Others:", otherScanners.map(\.number).map(String.init).joined(separator: ", "))

        let currentConnections = currentScanner.allBeaconsConnections()

        //                                      skip already detected scanners
        for scanner in otherScanners where !detectedScanners.contains(where: { $0.number == scanner.number }) {
            print("Other scanner:", scanner.number)

            for rotation in scanner.allRotations() {
                //
                let matchedConnections: [(other: Connection, current: Connection)] =
                    // Take all combination of both beacon connections
                    product(rotation.allBeaconsConnections(), currentConnections)
                    // Keep only the ones that have a matching vector
                    .filter { $0.0.vector == $0.1.vector }
                    .toArray()

                // TODO: how many connections should we expect at minimum?
                guard matchedConnections.isEmpty == false else {
                    continue
                }

                let matchedPointsInCurrent = currentScanner.beacons.filter { point in
                    matchedConnections.contains(where: { $0.current.origin == point || $0.current.destination == point }) // destionation shouldn't be needed cause it will match in the reverse connection
                }

                let matchedPointsInOther = rotation.beacons.filter { point in
                    matchedConnections.contains(where: { $0.other.origin == point || $0.other.destination == point }) // destionation shouldn't be needed cause it will match in the reverse connection
                }

                assert(matchedPointsInCurrent.count == matchedPointsInOther.count)
                guard matchedPointsInCurrent.count >= 12 else {
                    continue
                }

                print("\(currentScanner.number) matched \(scanner.number)")

                let matchesCount = matchedPointsInOther.count

                let pc = matchedConnections[0].current.origin
                let po = matchedConnections[0].other.origin
                let conversionVector = Point3(
                    pc.x - po.x,
                    pc.y - po.y,
                    pc.z - po.z
                )

                let convertedOther = Scanner(
                    number: rotation.number,
                    beacons: rotation.beacons.map { $0 + conversionVector }
                )

                // Make sure that the converted points that are in current are equal to the ones we found.
                assert(convertedOther.beacons.filter { currentScanner.beacons.contains($0) }.count == matchesCount)

                detectedScanners.append(convertedOther)

                // Gather centers for part 2
                let matchedCurrentSumVector = matchedPointsInCurrent.sum()
                let matchedOtherSumVector = matchedPointsInOther.sum()

                let center = Point3(
                    x: (matchedCurrentSumVector.x - matchedOtherSumVector.x) / matchesCount,
                    y: (matchedCurrentSumVector.y - matchedOtherSumVector.y) / matchesCount,
                    z: (matchedCurrentSumVector.z - matchedOtherSumVector.z) / matchesCount
                )
                gatherCenter(convertedOther, center)
            }
        }

        // Go next scanner
        // By taking the a known detected scanner as the next one we ensure that when we find a new one the coordinate
        // system conversion is straightforward because current will always be based on 0.
        // Instead if we followed the given order by the input we would find ourselve in situations were the matched scanner
        // and the current one are neither based on 0 so is way trickier to convert them.
        currentScanner = detectedScanners.drop(while: { $0.number != currentScanner.number }).dropFirst().first!
    }

    return detectedScanners
}

typealias Reports = [Scanner]

struct Scanner {
    let number: Int
    let beacons: [Point3]

    func allRotations() -> [Scanner] {
        rotations.map { rotation in
            Scanner(
                number: self.number,
                beacons: self.beacons.map { rotation($0) }
            )
        }
    }

    fileprivate func allBeaconsConnections() -> [Connection] {
        // TODO: Could use Algorithms permutations?
        var connections: [Connection] = []
        for point in beacons {
            for other in beacons {
                if other == point { continue }
                connections.append(.init(
                    origin: point,
                    destination: other,
                    vector: point.distance(to: other)
                ))
            }
        }
        return connections
    }
}

private struct Connection {
    let origin: Point3
    let destination: Point3
    let vector: Point3
}

typealias Vector3 = Point3
struct Point3: Hashable {
    var x: Int
    var y: Int
    var z: Int

    static func - (_ l: Point3, _ r: Point3) -> Vector3 {
        Vector3(x: l.x - r.x, y: l.y - r.y, z: l.z - r.z)
    }

    static func + (_ l: Point3, _ r: Point3) -> Vector3 {
        Vector3(x: l.x + r.x, y: l.y + r.y, z: l.z + r.z)
    }

    func distance(to other: Point3) -> Point3 {
        .init(
            x: x - other.x,
            y: y - other.y,
            z: z - other.z
        )
    }
}

extension Array where Element == Point3 {
    func sum() -> Point3 {
        reduce(into: .init(0, 0, 0)) { acc, point in
            acc.x += point.x
            acc.y += point.y
            acc.z += point.z
        }
    }
}

extension Vector3 {
    var magnitude: Int {
        abs(x) + abs(y) + abs(z)
    }
}

let rotations = fullRotations.map(\.0)

let fullRotations: [((Point3) -> Point3, (Point3) -> Point3)] = [
    ({ Point3($0.x, $0.y, $0.z) }, { Point3($0.x, $0.y, $0.z) }), //
    ({ Point3($0.x, $0.z, -$0.y) }, { Point3($0.x, -$0.z, $0.y) }), //
    ({ Point3($0.x, -$0.y, -$0.z) }, { Point3($0.x, -$0.y, -$0.z) }), //
    ({ Point3($0.x, -$0.z, $0.y) }, { Point3($0.x, $0.z, -$0.y) }), //
    ({ Point3(-$0.y, $0.x, $0.z) }, { Point3($0.y, -$0.x, $0.z) }), //
    ({ Point3(-$0.z, $0.x, -$0.y) }, { Point3($0.y, -$0.z, -$0.x) }), //
    ({ Point3($0.y, $0.x, -$0.z) }, { Point3($0.y, $0.x, -$0.z) }), //
    ({ Point3($0.z, $0.x, $0.y) }, { Point3($0.y, $0.z, $0.x) }), //
    ({ Point3(-$0.z, $0.y, $0.x) }, { Point3($0.z, $0.y, -$0.x) }), //
    ({ Point3($0.y, $0.z, $0.x) }, { Point3($0.z, $0.x, $0.y) }), //
    ({ Point3($0.z, -$0.y, $0.x) }, { Point3($0.z, -$0.y, $0.x) }), //
    ({ Point3(-$0.y, -$0.z, $0.x) }, { Point3($0.z, -$0.x, -$0.y) }), //
    ({ Point3(-$0.x, $0.y, -$0.z) }, { Point3(-$0.x, $0.y, -$0.z) }), //
    ({ Point3(-$0.x, $0.z, $0.y) }, { Point3(-$0.x, $0.z, $0.y) }), //
    ({ Point3(-$0.x, -$0.y, $0.z) }, { Point3(-$0.x, -$0.y, $0.z) }), //
    ({ Point3(-$0.x, -$0.z, -$0.y) }, { Point3(-$0.x, -$0.z, -$0.y) }), //
    ({ Point3($0.y, -$0.x, $0.z) }, { Point3(-$0.y, $0.x, $0.z) }), //
    ({ Point3(-$0.z, -$0.x, $0.y) }, { Point3(-$0.y, $0.z, -$0.x) }), //
    ({ Point3(-$0.y, -$0.x, -$0.z) }, { Point3(-$0.y, -$0.x, -$0.z) }), //
    ({ Point3($0.z, -$0.x, -$0.y) }, { Point3(-$0.y, -$0.z, $0.x) }), //
    ({ Point3($0.z, $0.y, -$0.x) }, { Point3(-$0.z, $0.y, $0.x) }), //
    ({ Point3($0.y, -$0.z, -$0.x) }, { Point3(-$0.z, $0.x, -$0.y) }), //
    ({ Point3(-$0.z, -$0.y, -$0.x) }, { Point3(-$0.z, -$0.y, -$0.x) }), //
    ({ Point3(-$0.y, $0.z, -$0.x) }, { Point3(-$0.z, -$0.x, $0.y) }), //
]
/* check revert rotations

  let p = Point3(459,-707,401)
  print(p)
  for rotation in (0..<24) {
      let rotated = p.rotated(rotation)
 //        print(rotated)
      let reverted = rotated.undoRotated(rotation)
      print(rotation, reverted)
      print(rotation, p == reverted)
  }

  exit(0)
  */

extension Point3 {
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }
}

extension Vector3 {
    func matches(_ other: Vector3) -> Bool {
        self == other
    }
}

/*
 - scanner can report the positions of all detected beacons relative to itself,
 - scanners do not know their own position
 - finding pairs of scanners that have overlapping detection regions such that there are at least
 12 beacons that both scanners detect within the overlap
 -
 */
