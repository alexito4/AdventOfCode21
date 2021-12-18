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

    var isUppercase: Bool {
        first(where: \.isLowercase) == nil
    }

    var isLowercase: Bool {
        first(where: \.isUppercase) == nil
    }
}

extension Bool {
    init(zeroOrOne: Int) {
        assert(zeroOrOne == 0 || zeroOrOne == 1)
        self = zeroOrOne == 0 ? false : true
    }
}
