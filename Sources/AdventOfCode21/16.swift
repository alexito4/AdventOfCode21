import Foundation
import Parsing

let day16 = Problem(
    day: 16,
//    rawExample: "D2FE28",
//    rawExample: "8A004A801A8002F478", // 16
//    rawExample: "620080001611562C8802118E34", // 12
//    rawExample: "C0015000016115A2E0802F182340", // 23
//    rawExample: "A0016C880162017C3686B18A3D4780", // 31
    rawExample: "880086C3E88112", // _ /
    parse: parse(_:),
    solve: sumVersionNumbers(_:),
    solve2: evaluate(_:)
)

private func parse(_ input: String) -> Packet {
//    var literal = input.toBinaryString[...]
//    assert(literal == "110100101111111000101000")
//    assert(_parsePacket(&literal)?.literalValue == 2021)
//
//    var opLengthId0 = "38006F45291200".toBinaryString[...]
//    assert(opLengthId0 == "00111000000000000110111101000101001010010001001000000000")
//    _parsePacket(&opLengthId0)
//
//    var opLengthId1 = "EE00D40C823060".toBinaryString[...]
//    assert(opLengthId1 == "11101110000000001101010000001100100000100011000001100000")
//    _parsePacket(&opLengthId1)

    var copy = input.toBinaryString[...]
    return _parsePacket(&copy)!
}

// add up all of the version numbers
private func sumVersionNumbers(_ input: Packet) throws -> Int {
    input.sumVersions()
}

//  evaluate the expression
private func evaluate(_ input: Packet) -> Int {
    input.evaluate()
}

struct Packet {
    let version: Int
    let data: Content

    enum Content {
        case literal(Int)
        case subpackets(Operation, [Packet])
    }

    enum Operation: Int {
        case sum = 0
        case product = 1
        case minimum = 2
        case maximum = 3
        case greaterThan = 5
        case lessThan = 6
        case equalTo = 7
    }

    var literalValue: Int? {
        switch data {
        case let .literal(number): return number
        default: return nil
        }
    }

    func sumVersions() -> Int {
        var sum = version
        if case let .subpackets(_, packets) = data {
            sum += packets.reduce(0) { $0 + $1.sumVersions() }
        }
        return sum
    }

    func evaluate() -> Int {
        switch data {
        case let .literal(number):
            return number
        case let .subpackets(operation, array):
            switch operation {
            case .sum:
                return array.reduce(0) { $0 + $1.evaluate() }
            case .product:
                return array.reduce(1) { $0 * $1.evaluate() }
            case .minimum:
                return array.map { $0.evaluate() }.min()!
            case .maximum:
                return array.map { $0.evaluate() }.max()!
            case .greaterThan:
                assert(array.count == 2)
                return array[0].evaluate() > array[1].evaluate() ? 1 : 0
            case .lessThan:
                assert(array.count == 2)
                return array[0].evaluate() < array[1].evaluate() ? 1 : 0
            case .equalTo:
                assert(array.count == 2)
                return array[0].evaluate() == array[1].evaluate() ? 1 : 0
            }
        }
    }
}

private func _parsePacket(_ input: inout Substring) -> Packet? {
    // Parse Header
    guard let (version, typeId) = headerParser.parse(&input) else { return nil }

    let data: Packet.Content

    switch typeId {
    case 4:
        let literal = parseLiteral(&input).let { Int($0, radix: 2) }
        data = .literal(literal!)
    default: // Parse Operator
        let operation = Packet.Operation(rawValue: typeId)!
        guard let lengthTypeId = Int.binaryParser(digits: 1).parse(&input) else { return nil }
        switch lengthTypeId {
        //  next 15 bits are a number that represents the total length in bits of the sub-packets
        case 0:
            var totalLength = Int.binaryParser(digits: 15).parse(&input)!
            var subpackets: [Packet] = []
            while totalLength > 0 {
                var length = input.count
                let packet = _parsePacket(&input)!
                length -= input.count
                totalLength -= length
                subpackets.append(packet)
            }
//                print(subpackets)
            data = .subpackets(operation, subpackets)
        // next 11 bits are a number that represents the number of sub-packets immediately contained by this packet.
        case 1:
            let numberOfSubpackets = Int.binaryParser(digits: 11).parse(&input)!
            var subpackets: [Packet] = []
            for _ in 1...numberOfSubpackets {
                let packet = _parsePacket(&input)!
                subpackets.append(packet)
            }
//                print(subpackets)
            data = .subpackets(operation, subpackets)
        default: fatalError()
        }
    }

    return Packet(version: version, data: data)
}

private let versionParser = Int.binaryParser(digits: 3)
private let typeIdParser = Int.binaryParser(digits: 3)
private let headerParser = versionParser.take(typeIdParser)

// 10111 11110 00101 000   -> 011111100101  ->  2021
// first bit. all groups have 1 except the last group that has 0
private func parseLiteral(_ input: inout Substring) -> String {
    var wasLastOne = false
    var groups: [String] = []
    while !wasLastOne {
        let group = Int.binaryParser(digits: 1)
            .take(Prefix(4).map { String($0) })
            .parse(&input)!
        groups.append(group.1)
        if group.0 == 0 {
            wasLastOne = true
        }
    }
    return groups.joined()
}

private extension String {
    var toBinaryString: String {
        let binaryString = compactMap { hexToBinary[$0] }.joined()
        let count = binaryString.count
        let mod = count % 4
        if mod != 0 {
            let padding = count + (4 - count % 4)
            return binaryString.leftPadding(to: padding, with: "0")
        } else {
            return binaryString
        }
    }
}

private let hexToBinary: [Character: String] = [
    "0": "0000",
    "1": "0001",
    "2": "0010",
    "3": "0011",
    "4": "0100",
    "5": "0101",
    "6": "0110",
    "7": "0111",
    "8": "1000",
    "9": "1001",
    "A": "1010",
    "B": "1011",
    "C": "1100",
    "D": "1101",
    "E": "1110",
    "F": "1111",
]

private enum TypeId {
    case literal(Int)
}

private func stringToBinary(_ s: Substring) -> Int {
    Int(s, radix: 2)!
}
