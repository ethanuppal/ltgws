// Copyright (C) 2023 Ethan Uppal. All rights reserved.

/// An n-order transition matrix.
indirect enum TransitionMatrix: CustomDebugStringConvertible {
    typealias Table = [String: TransitionMatrix]

    case count(Int)
    case probability(Double)
    case matrix(Table)

    var debugDescription: String {
        return makeDebugDescription(preindentTable: true)
    }

    init<C: Collection>(tokens: C, order: Int) where C.Element == String, C.Index == Int {
        var table = Table()
        if order == 0 {
            TransitionMatrix.fill(table: &table, tokens: tokens)
        } else {
            for i in 0 ..< tokens.count - order {
                let sequence = tokens[i ..< i + order + 1]
                TransitionMatrix.merge(table: &table, sequence: sequence)
            }
        }
        self = .matrix(table).normalized()
    }

    func asProbabilities() -> [String:Double] {
        switch self {
        case .matrix(let table):
            return table.mapValues {
                switch $0 {
                case .probability(let p):
                    return p
                default:
                    fatalError("Should not get here")
                }
            }
        default:
            fatalError("Should not get here")
        }
    }

    subscript<C: Collection>(tokens: C) -> TransitionMatrix? where C.Element == String, C.Index == Int {
        if tokens.isEmpty {
            return self
        }
        switch self {
        case .count, .probability:
            return nil
        case .matrix(let table):
            return table[tokens[tokens.startIndex]]?[tokens[(tokens.startIndex + 1)...]]
        }
    }

    private mutating func increment() {
        switch self {
        case .count(let n):
            self = .count(n + 1)
        default:
            break
        }
    }

    private func isCount() -> Bool {
        switch self {
        case .count:
            return true
        default:
            return false
        }
    }

    private func asCount() -> Int {
        switch self {
        case .count(let n):
            return n
        default:
            fatalError("Should not get here")
        }
    }

    private func asTable() -> Table {
        switch self {
        case .matrix(let table):
            return table
        default:
            fatalError("Should not get here")
        }
    }

    private func normalized() -> TransitionMatrix {
        switch self {
        case .count:
            return self
        case .probability:
            return self
        case .matrix(let table):
            let n: Double = ((table.first?.value.isCount() ?? false)
                ? Double(table.reduce(0) { $0 + $1.value.asCount() })
                : 1)
            let normalizedTable: Table = table.mapValues {
                switch $0 {
                case .count(let m):
                    return .probability(Double(m) / n)
                default:
                    return $0.normalized()
                }
            }
            return .matrix(normalizedTable)
        }
    }

    private static func fill<S: Sequence>(table: inout Table, tokens: S) where S.Element == String {
        for token in tokens {
            if table[token] == nil {
                table[token] = .count(1)
            } else {
                table[token]!.increment()
            }
        }
    }

    private static func merge<C: Collection>(table: inout Table, sequence: C) where C.Element == String, C.Index == Int {
        if sequence.isEmpty {
            return
        }

        let token = sequence.first!
        if sequence.count == 1 {
            if table[token] == nil {
                table[token] = .count(1)
            } else {
                table[token]!.increment()
            }
        } else {
            let nextSequence = sequence[(sequence.startIndex + 1)...]

            var subtable = table[token].map { $0.asTable() } ?? Table()
            TransitionMatrix.merge(table: &subtable, sequence: nextSequence)
            table[token] = .matrix(subtable)
        }
    }

    private func makeDebugDescription(indent: Int = 2, preindentTable: Bool = false) -> String {
        var result = ""
        let pre = String(repeating: " ", count: indent)
        switch self {
        case .count(let n):
            result += "\(preindentTable ? pre : "")N(\(n))\n"
        case .probability(let p):
            result += "\(preindentTable ? pre : "")P(\(p))\n"
        case .matrix(let table):
            result += "\(preindentTable ? pre : "")T(\n"
            for (token, matrix) in table {
                result += "\(pre)\"\(token)\": " + matrix.makeDebugDescription(indent: indent + 2)
            }
            result += "\(pre))\n"
        }
        return result
    }
}
