import Foundation

func binaryCompare<T, P>(_ part: KeyPath<T, P>, by areInIncreasingOrder: @escaping (P, P) -> Bool) -> ((T, T) -> Bool) {
    return { l, r in
        areInIncreasingOrder(l[keyPath: part], r[keyPath: part])
    }
}

// extension Task where Failure == Never {
//    static func runBlocking(
//        priority: TaskPriority? = nil,
//        operation: @escaping @Sendable () async -> Success
//    ) throws -> Success {
//        let semaphore = DispatchSemaphore(value: 0)
//        var result: Success!
//        Task(priority: priority) {
//            result = await operation()
//            semaphore.signal()
//        }
//        semaphore.wait()
//        return result
//    }
// }

extension Task where Success == Void, Failure == Never {
    static func unsafeAwaiting(_ f: @escaping () async -> Void) {
        let sema = DispatchSemaphore(value: 0)
        Task {
            await f()
            sema.signal()
        }
        sema.wait()
    }
}

extension String {
    func leftPadding(to length: Int, with character: Character = " ") -> String {
        if count >= length {
            return self
        } else {
            let pad = String(repeating: character, count: length - count)
            return "\(pad)\(self)"
        }
    }
}

extension Bool {
    init(zeroOrOne: Int) {
        assert(zeroOrOne == 0 || zeroOrOne == 1)
        self = zeroOrOne == 0 ? false : true
    }
}

// MARK: - Collections

import BitArrayModule

extension BitArray {
    var binaryRepresentation: Int {
        map { $0 ? "1" : "0" }
            .joined()
            .let { Int($0)! }
    }

    var decimalRepresentation: Int {
        map { $0 ? "1" : "0" }
            .joined()
            .let { Int($0, radix: 2)! }
    }
}

extension Array {
    mutating func mutateEach(by transform: (inout Element) throws -> LoopReturn) rethrows {
        for i in indices {
            switch try transform(&self[i]) {
            case .continue: continue
            case .break: break
            }
        }
    }
}

enum LoopReturn {
    case `continue`
    case `break`
}

extension Collection where Element == Int {
    func sum() -> Element {
        reduce(0, +)
    }

    func average() -> Double {
        let sum = Double(sum())
        return sum / Double(count)
    }

    func median() -> Double {
        let count = Double(count)
        if count == 0 { return 0 }
        let sorted = sorted { $0 < $1 }

        if count.truncatingRemainder(dividingBy: 2) == 0 {
            // Even number of items - return the mean of two middle values
            let leftIndex = Int(count / 2 - 1)
            let leftValue = Double(sorted[leftIndex])
            let rightValue = Double(sorted[leftIndex + 1])
            return (leftValue + rightValue) / 2.0
        } else {
            // Odd number of items - take the middle item.
            return Double(sorted[Int(count / 2)])
        }
    }
}

// MARK: - Parsing

import Parsing

public struct AllSpace<Input>: Parser
    where
    Input: Collection,
    Input.SubSequence == Input,
    Input.Element == UTF8.CodeUnit
{
    @inlinable
    public init() {}

    @inlinable
    public func parse(_ input: inout Input) -> Input? {
        let output = input.prefix(while: { (byte: UTF8.CodeUnit) in
            byte == .init(ascii: " ")
                || byte == .init(ascii: "\t")
        })
        input.removeFirst(output.count)
        return output
    }
}

extension Parsers {
    static let oneSpace = StartsWith<Substring>(" ")
    static let allSpace = AllSpace<Substring.UTF8View>()
        .pullback(\Substring.utf8)
    static let newLine = Newline<Substring.UTF8View>().pullback(\Substring.utf8)
}

extension Parser where Input == Substring {
    func test(_ input: String) -> Output? {
        fullParse(input, debug: true)
    }

    func fullParse(_ input: String, debug: Bool = false) -> Output? {
        var copy = input[...]
        let output = parse(&copy)
        if debug {
            print(output ?? "")
            print("Rest >\(copy)<")
        } else {
            assert(copy.isEmpty)
        }
        return output
    }
}
