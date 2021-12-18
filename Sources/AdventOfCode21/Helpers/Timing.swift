import Foundation
import TabularData
func time() {
    let columnDay = ColumnID("Day", Int.self)
    let columnPart = ColumnID("Part", Int.self)
    let columnTime = ColumnID("Time (ms)", CFAbsoluteTime.self)

    var data = DataFrame()
    data.append(column: Column(columnDay, capacity: 0))
    data.append(column: Column(columnPart, capacity: 0))
    data.append(column: Column(columnTime, capacity: 0))
    func timePart(_ part: TimeableProblemPart) {
//        data.appendEmptyRow()
//        data.append(row: 1, 2, 4.0)
        data.append(row: part.day, part.part, part.time() * 1000)
    }
    for problem in allProblems {
        timePart(problem.part1)
        timePart(problem.part2)
    }

    let format = FormattingOptions(
        maximumLineWidth: Int.max,
        maximumRowCount: 100,
        includesColumnTypes: false
    )
    print(
        data
//            .sorted(on: columnTime)
            .description(options: format)
    )
    var summary = data.summary(of: columnTime.name)
        .selecting(columnNames: "mean")
    summary.renameColumn("mean", to: "Mean (ms)")
    summary.insert(column: Column<CFAbsoluteTime>(name: "Total (ms)", contents: [data[columnTime].sum()]), at: 0)
    print(summary.description(options: format))
}

struct TimeableProblem {
    let part1: TimeableProblemPart
    let part2: TimeableProblemPart

    init<I, O>(_ problem: Problem<I, O>) {
        part1 = TimeableProblemPart(problem.part1)
        part2 = TimeableProblemPart(problem.part2)
    }
}

struct TimeableProblemPart {
    var day: Int
    var part: Int
    var time: () -> CFAbsoluteTime

    init<Input, Output>(_ part: ProblemPart<Input, Output>) {
        day = part.day
        self.part = part.part
        time = {
            let contents = try! readFile(day: "\(part.day)")
            let input = part.parse(contents)
            let start = CFAbsoluteTimeGetCurrent()
            _ = try! part.solve(input)
            let diff = CFAbsoluteTimeGetCurrent() - start
            return diff
        }
    }
}

extension Problem {
    var timeable: TimeableProblem {
        .init(self)
    }
}

var allProblems: [TimeableProblem] = [
    day1.timeable,
    day2.timeable,
    day3.timeable,
    day4.timeable,
    day5.timeable,
    day6.timeable,
    day7.timeable,
    day8.timeable,
    day9.timeable,
    day10.timeable,
    day11.timeable,
]
