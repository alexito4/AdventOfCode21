import Collections
import Swift

/// A double-ended priority queue built on top of `Heap`.
public struct PriorityQueue<Value, Priority: Comparable> {
    public typealias Pair = (value: Value, priority: Priority)

    @usableFromInline
    struct _Element: Comparable {
        @usableFromInline let value: Value
        let priority: Priority
        let insertionCounter: UInt64

        @usableFromInline
        init(value: Value, priority: Priority, insertionCounter: UInt64) {
            self.value = value
            self.priority = priority
            self.insertionCounter = insertionCounter
        }

        @usableFromInline
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.priority == rhs.priority
        }

        @usableFromInline
        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.priority < rhs.priority {
                return true
            } else if lhs.priority == rhs.priority {
                return lhs.insertionCounter < rhs.insertionCounter
            } else {
                return false
            }
        }
    }

    @usableFromInline
    internal var _base: Heap<_Element>

    @usableFromInline
    internal var _insertionCounter: UInt64 = 0

    /// A Boolean value indicating whether or not the queue is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var isEmpty: Bool {
        _base.isEmpty
    }

    /// The number of items in the queue.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var count: Int {
        _base.count
    }

    /// Creates an empty queue.
    @inlinable
    public init() {
        _base = Heap()
    }

    // MARK: -

    /// Inserts the given item into the queue.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func insert(_ value: Value, priority: Priority) {
        defer { _insertionCounter += 1 }

        let pair = _Element(
            value: value,
            priority: priority,
            insertionCounter: _insertionCounter
        )

        _base.insert(pair)
    }

    /// Returns the item with the lowest priority, if available.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func min() -> Value? {
        _base.min()?.value
    }

    /// Returns the item with the highest priority, if available.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func max() -> Value? {
        _base.max()?.value
    }

    /// Removes and returns the item with the lowest priority, if available.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popMin() -> Value? {
        _base.popMin()?.value
    }

    /// Removes and returns the item with the highest priority, if available.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popMax() -> Value? {
        _base.popMax()?.value
    }

    /// Removes and returns the element with the lowest priority.
    ///
    /// The queue *must not* be empty.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func removeMin() -> Value {
        _base.removeMin().value
    }

    /// Removes and returns the element with the highest priority.
    ///
    /// The queue *must not* be empty.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func removeMax() -> Value {
        _base.removeMax().value
    }
}

// MARK: -

public extension PriorityQueue {
    /// Initializes a queue from a sequence.
    ///
    /// - Complexity: O(n), where `n` is the length of `elements`.
    @inlinable
    init<S: Sequence>(_ elements: S) where S.Element == Pair {
        _base = Heap(
            elements
                .enumerated()
                .map {
                    _Element(
                        value: $0.element.value,
                        priority: $0.element.priority,
                        insertionCounter: UInt64($0.offset)
                    )
                }
        )
        _insertionCounter = UInt64(_base.count)
    }
}

extension PriorityQueue: ExpressibleByDictionaryLiteral {
    /// Creates a new priority queue from the contents of a dictionary literal.
    ///
    /// **Do not call this initializer directly.** It is used by the compiler when
    /// you use a dictionary literal. Instead, create a new queue using a
    /// dictionary literal as its value by enclosing a comma-separated list of
    /// values in square brackets. You can use a dictionary literal anywhere a
    /// priority queue is expected by the type context.
    ///
    /// - Parameter elements: A variadic list of element-priority pairs for the new
    ///                       queue.
    @inlinable
    public init(dictionaryLiteral elements: (Value, Priority)...) {
        self.init(elements)
    }
}

extension PriorityQueue: ExpressibleByArrayLiteral {
    /// Creates a new priority queue from the contents of an array literal.
    ///
    /// **Do not call this initializer directly.** It is used by the compiler when
    /// you use an array literal. Instead, create a new priority queue using an
    /// array literal as its value by enclosing a comma-separated list of values
    /// in square brackets. You can use an array literal anywhere a priority queue
    /// is expected by the type context.
    ///
    /// - Parameter elements: A variadic list of tuples containing the element
    ///                       and its priority (in that order).
    @inlinable
    public init(arrayLiteral elements: Pair...) {
        self.init(elements)
    }
}
