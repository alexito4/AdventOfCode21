import Foundation
import Overture
import Parsing
import PriorityQueueModule

let day15 = Problem(
    day: 15,
    rawExample: """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581

    """,
    parse: parse(_:),
    solve: calculateLowestRisk(_:), // 40    |    685
    solve2: pipe(enlargeMap(_:), calculateLowestRisk(_:)) // 315    |   2995
)

private func parse(_ input: String) -> Map2d {
    let parseDigit = First<Substring>()
        .map(String.init).map { $0[...] }
        .pipe(Int.parser())

    let parseLine = Many(parseDigit, atLeast: 1)

    let parser = Many(
        parseLine,
        atLeast: 1,
        separator: "\n"
    )
    .skipFinalLine()
    return parser.fullParse(input)!
}

// What is the lowest total risk of any path from the top left to the bottom right?
private func calculateLowestRisk(_ input: Map2d) throws -> Int {
    let startPoint = input.topLeftPoint
    let endPoint = input.bottomRightPoint

    // A*
    // https://www.redblobgames.com/pathfinding/a-star/implementation.html#csharp

    var cameFrom = [Point: Point]()
    var costSoFar = [Point: Int]()

    func heuristic(from point: Point) -> Int {
        abs(point.x - endPoint.x) + abs(point.y - endPoint.y)
    }

    var frontier = PriorityQueue<Point, Int>()
    frontier.insert(startPoint, priority: 0)

    cameFrom[startPoint] = startPoint
    costSoFar[startPoint] = 0

    while !frontier.isEmpty {
//        print(">>><<<")
//        print(input.drawAstar(frontier: frontier))

        let current = frontier.popMin()! // Use min because the priority is the cost, so less priority is better.

        if current == endPoint {
            break
        }

        for neighbor in input.adjecent4PointsOf(current) {
            let newCost = costSoFar[current, default: 0] + input[neighbor]

            if costSoFar[neighbor] == nil || newCost < costSoFar[neighbor]! {
                costSoFar[neighbor] = newCost
                let priority = newCost + heuristic(from: neighbor)
                frontier.insert(neighbor, priority: priority)
                cameFrom[neighbor] = current
            }
        }
    }

    // Reconstruct path
    var current = endPoint
    var path = [current]
    while current != startPoint {
        let prev = cameFrom[current]!
        path.append(prev)
        current = prev
    }
    path.reverse()

    let cost = path.reduce(0) { $0 + input[$1] } - input[startPoint]
    return cost
}

// In a five times bigger map
private func enlargeMap(_ input: Map2d) throws -> Map2d {
//    print(input.draw())
//    print("=====")
    assert(input.count == input[0].count)
    let originalSize = input.count
    let size = originalSize * 5
    let sizedMap = Map2d(repeating: Array(repeating: 0, count: size), count: size)
    let newMap = sizedMap.mapPointsAndValues { value, point in
        let originalPoint = Point(x: point.x % originalSize, y: point.y % originalSize)
        let originalValue = input[originalPoint]

        let increase = (point.x / originalSize) + (point.y / originalSize)
        let newValue = (originalValue + increase - 1) % 9 + 1

        value = newValue
    }

//    print(Array(repeating: (0...9).map(String.init), count: 5).flatMap { $0 }.joined())
//    print(Array(repeating: "_", count: size).joined())
//    print(newMap.draw())
    return newMap
}

extension Map2d {
    func drawAstar(path: [Point]) -> String {
        mapPointsAndValues { value, point in
            if path.contains(point) {
                // keep value
            } else {
                value = 0
            }
        }
        .draw()
        .replacingOccurrences(of: "0", with: ".")
    }

    func drawAstar(frontier: PriorityQueue<Point, Int>) -> String {
        var gather = Set<Point>()
        var copy = frontier
        while !copy.isEmpty {
            gather.insert(copy.removeMax())
        }
        return mapPointsAndValues { value, point in
            if gather.contains(point) {
                // keep value
            } else {
                value = 0
            }
        }
        .draw()
        .replacingOccurrences(of: "0", with: ".")
    }
}

let exampleBigMap = pipe({ exampleBigMapString }, parse(_:))(())
let exampleBigMapString = """
11637517422274862853338597396444961841755517295286
13813736722492484783351359589446246169155735727126
21365113283247622439435873354154698446526571955763
36949315694715142671582625378269373648937148475914
74634171118574528222968563933317967414442817852555
13191281372421239248353234135946434524615754563572
13599124212461123532357223464346833457545794456865
31254216394236532741534764385264587549637569865174
12931385212314249632342535174345364628545647573965
23119445813422155692453326671356443778246755488935
22748628533385973964449618417555172952866628316397
24924847833513595894462461691557357271266846838237
32476224394358733541546984465265719557637682166874
47151426715826253782693736489371484759148259586125
85745282229685639333179674144428178525553928963666
24212392483532341359464345246157545635726865674683
24611235323572234643468334575457944568656815567976
42365327415347643852645875496375698651748671976285
23142496323425351743453646285456475739656758684176
34221556924533266713564437782467554889357866599146
33859739644496184175551729528666283163977739427418
35135958944624616915573572712668468382377957949348
43587335415469844652657195576376821668748793277985
58262537826937364893714847591482595861259361697236
96856393331796741444281785255539289636664139174777
35323413594643452461575456357268656746837976785794
35722346434683345754579445686568155679767926678187
53476438526458754963756986517486719762859782187396
34253517434536462854564757396567586841767869795287
45332667135644377824675548893578665991468977611257
44961841755517295286662831639777394274188841538529
46246169155735727126684683823779579493488168151459
54698446526571955763768216687487932779859814388196
69373648937148475914825958612593616972361472718347
17967414442817852555392896366641391747775241285888
46434524615754563572686567468379767857948187896815
46833457545794456865681556797679266781878137789298
64587549637569865174867197628597821873961893298417
45364628545647573965675868417678697952878971816398
56443778246755488935786659914689776112579188722368
55172952866628316397773942741888415385299952649631
57357271266846838237795794934881681514599279262561
65719557637682166874879327798598143881961925499217
71484759148259586125936169723614727183472583829458
28178525553928963666413917477752412858886352396999
57545635726865674683797678579481878968159298917926
57944568656815567976792667818781377892989248891319
75698651748671976285978218739618932984172914319528
56475739656758684176786979528789718163989182927419
67554889357866599146897761125791887223681299833479
"""
