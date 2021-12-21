
import Parsing
import Combine

extension Parser where Input == Substring {
    func skipFinalLine() -> AnyParser<Input, Output> {
        skip(Whitespace().pullback(\.utf8))
            .skip(End())
            .eraseToAnyParser()
    }
}

extension Int {
    static func binaryParser(digits: Int) -> AnyParser<Substring, Int> {
        Prefix<Substring>(digits)
            .flatMap { str -> AnyParser<Substring, Int> in
                if let number = Int(str, radix: 2) {
                    return Always(number).eraseToAnyParser()
                } else {
                    return Fail().eraseToAnyParser()
                }
            }
            .eraseToAnyParser()
    }
}

extension Parser {
    func `guard`(
        _ f: @escaping (Self.Output) -> Bool
    ) -> AnyParser<Self.Input, Self.Output>
    {
        self.flatMap { input -> AnyParser<Self.Input, Self.Output> in
            guard f(input) else { return Fail().eraseToAnyParser() }
            return Always(input).eraseToAnyParser()
        }
        .eraseToAnyParser()
    }
}

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
