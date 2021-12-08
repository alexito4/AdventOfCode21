import Foundation
import Parsing

//

let day4 = Problem(
    day: 4,
    rawExample: """
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
     8  2 23  4 24
    21  9 14 16  7
     6 10  3 18  5
     1 12 20 15 19

     3 15  0  2 22
     9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
     2  0 12  3  7
    """,
    parse: parseBingo,
    solve: findFirstWinner(_:), //   4512      63552
    solve2: findLastWinner(_:)
)

struct Bingo: CustomDebugStringConvertible {
    typealias Draw = [Int]
    typealias Board = [[Int]]
    let draw: Draw
    let boards: [Board]

    var debugDescription: String {
        var out = ""
        print("Draw:", draw, to: &out)
        for (i, board) in boards.enumerated() {
            print("Board \(i + 1):", board, to: &out)
        }
        return out
    }
}

private func parseBingo(_ input: String) -> Bingo {
    let oneSpace = StartsWith<Substring>(" ")
    let allSpace = AllSpace<Substring.UTF8View>()
        .pullback(\Substring.utf8)
    let newLine = Newline<Substring.UTF8View>().pullback(\Substring.utf8)

    let drawParser = Many(Int.parser(), separator: ",")
        .skip(newLine)

    let _lineParserWithoutLeadingSpace = Many(
        Int.parser(),
        atLeast: 1,
        separator: allSpace
    )
    let lineParser = Skip(oneSpace).take(_lineParserWithoutLeadingSpace)
        .orElse(_lineParserWithoutLeadingSpace)

    let bingoParser = Many(lineParser, atLeast: 1, separator: newLine)

    let allBingosParser = Many(bingoParser, separator: Whitespace().pullback(\.utf8))

    let parser = drawParser
        .skip(allSpace).skip(newLine)
        .take(allBingosParser)
        .map(Bingo.init(draw:boards:))

    var copy = input[...]
    let output = parser.parse(&copy)
    return output!
}

struct PlayingBoard {
    struct Number {
        let n: Int
        var marked: Bool
    }

    var rows: [[Number]]

    mutating func markNumber(_ draw: Int) {
        rows.mutateEach {
            $0.mutateEach {
                if $0.n == draw {
                    $0.marked = true
                    return .break
                } else {
                    return .continue
                }
            }
            return .continue
        }
    }

    func checkRows() -> Bool {
        rows.contains { row in
            row.allSatisfy(\.marked)
        }
    }

    func checkColumns() -> Bool {
        var candidateColumns = IndexSet(rows.indices)
        for row in rows {
            for c in row.indices.filter({ candidateColumns.contains($0) }) {
                if !row[c].marked {
                    candidateColumns.remove(c)
                }
            }
        }
        return !candidateColumns.isEmpty
    }

    func isWinner() -> Bool {
        checkRows() || checkColumns()
    }

    func unmarkedSum() -> Int {
        rows.lazy
            .joined()
            .filter { !$0.marked }
            .map(\.n)
            .reduce(0, +)
    }
}

func findFirstWinner(_ input: Bingo) throws -> (boardIndex: Int, score: Int) {
    var boards = input.boards.map { PlayingBoard(rows: $0.map { $0.map { PlayingBoard.Number(n: $0, marked: false) } }) }

    var score: Int?
    var boardIndex: Int?
    loop: for draw in input.draw {
        for i in boards.indices {
            var board = boards[i]
            defer { boards[i] = board }
            board.markNumber(draw)
            if board.isWinner() {
                let unmarkedSum = board.unmarkedSum()
                score = unmarkedSum * draw
                boardIndex = i
                break loop
            }
        }
    }
    return (boardIndex!, score!)
}

func findLastWinner(_ input: Bingo) throws -> (boardIndex: Int, score: Int) {
    var boards = input.boards.map { PlayingBoard(rows: $0.map { $0.map { PlayingBoard.Number(n: $0, marked: false) } }) }
    var candidates = IndexSet(boards.indices)

    var score: Int?
    var boardIndex: Int?
    loop: for draw in input.draw {
        for i in candidates {
            var board = boards[i]
            defer { boards[i] = board }
            board.markNumber(draw)
            if board.isWinner() {
                if candidates.count == 1 {
                    // The last winner!
                    let unmarkedSum = board.unmarkedSum()
                    score = unmarkedSum * draw
                    boardIndex = i
                    break loop
                }
                candidates.remove(i)
            }
        }
    }
    return (boardIndex!, score!)
}
