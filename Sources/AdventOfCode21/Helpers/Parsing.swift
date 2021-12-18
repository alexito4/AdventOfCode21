
import Parsing

extension Parser where Input == Substring {
    func finalLine() -> AnyParser<Input, Output> {
        skip(
            End()
                .orElse(
                    Skip("\n")
                        .skip(End())
                )
        )
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
