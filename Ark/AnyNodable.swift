//
//  AnyNodable.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/9/1.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import AsyncDisplayKit

@usableFromInline
internal protocol _AnyNodableBox {
    var _canonicalBox: _AnyNodableBox { get }
    
    /// Determine whether values in the boxes are equivalent
    ///
    /// - Precondition: `self` and `box` are in canonical form.
    /// - Returns: `nil` to indicate that the boxes store different types, so
    ///   no comparison is possible. Otherwise, contains the result of `==`.
    func _isEqual(to box: _AnyNodableBox) -> Bool?
    var _diffIdentifier: AnyHashable { get }
    func _nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock
    func _sizeRange(in context: NodeContext) -> ASSizeRange
    
    var _base: Any { get }
    func _unbox<T: Nodable>() -> T?
}

extension _AnyNodableBox {
    var _canonicalBox: _AnyNodableBox {
        self
    }
}

internal struct _ConcretNodableBox<Base: Nodable>: _AnyNodableBox {
    internal var _baseNodable: Base
    
    internal init(_ base: Base) {
        self._baseNodable = base
    }
    
    internal func _unbox<T: Nodable>() -> T? {
        return (self as _AnyNodableBox as? _ConcretNodableBox<T>)?._baseNodable
    }
    
    internal func _isEqual(to rhs: _AnyNodableBox) -> Bool? {
        if let rhs: Base = rhs._unbox() {
            return _baseNodable == rhs
        }
        return nil
    }
    
    internal var _diffIdentifier: AnyHashable {
        _baseNodable.diffIdentifier
    }
    
    internal func _nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        _baseNodable.nodeBlock(with: channel, indexPath: indexPath)
    }
    
    internal func _sizeRange(in context: NodeContext) -> ASSizeRange {
        _baseNodable.sizeRange(in: context)
    }
    
    internal var _base: Any {
        return _baseNodable
    }
    
    internal func _downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool {
        guard let value = _baseNodable as? T else { return false }
        result.initialize(to: value)
        return true
    }
}

/// A type-erased nodable value.
///
/// The `AnyNodable` type forwards equality comparisons
/// to an underlying equatable value, hiding the type of
/// the wrapped value.

@frozen
public struct AnyNodable {
    internal var _box: _AnyNodableBox
    
    internal init(_box box: _AnyNodableBox) {
        self._box = box
    }
    
    /// Creates a type-erased nodable value that wraps the give instance.
    ///
    /// - Parameter base: A nodable value to wrap.
    public init<N: Nodable>(_ base: N) {
        self.init(_box: _ConcretNodableBox(base))
    }
    
    public var base: Any {
        _box._base
    }
}

extension AnyNodable: Nodable {
    
    /// Returns a Boolean value indicating whether two type-erased nodable
    /// instances wrap the same value.
    ///
    /// - Parameters:
    ///   - lhs: A type-erased nodable value.
    ///   - rhs: Another type-erased nodable value.
    public static func == (lhs: AnyNodable, rhs: AnyNodable) -> Bool {
        lhs._box._canonicalBox._isEqual(to: rhs._box._canonicalBox) ?? false
    }
    
    public var diffIdentifier: AnyHashable {
        _box._canonicalBox._diffIdentifier
    }
    
    public func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        _box._canonicalBox._nodeBlock(with: channel, indexPath: indexPath)
    }
    
    public func sizeRange(in context: NodeContext) -> ASSizeRange {
        _box._canonicalBox._sizeRange(in: context)
    }
}

extension AnyNodable: CustomStringConvertible {
    public var description: String {
        String(describing: base)
    }
}

extension AnyNodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "AnyNodable(" + String(reflecting: base) + ")"
    }
}

extension AnyNodable: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(
            self,
            children: ["value": base])
    }
}
