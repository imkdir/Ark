//
//  AnyNodable.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/9/1.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public struct AnyNodable: Nodable {

    internal let base: Any
    public let diffIdentifier: AnyHashable
    public let nodeBlock: (NodeChannel, IndexPath) -> ASCellNodeBlock
    public let sizeRange: (NodeContext) -> ASSizeRange
    
    public init<T>(_ base: T) where T: Nodable {
        self.base = base as Any
        self.diffIdentifier = base.diffIdentifier
        self.nodeBlock = base.nodeBlock(with:indexPath:)
        self.sizeRange = base.sizeRange(in:)
    }
    
    public func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        nodeBlock(channel, indexPath)
    }
    
    public func sizeRange(in context: NodeContext) -> ASSizeRange {
        sizeRange(context)
    }
    
    public static func == (lhs: AnyNodable, rhs: AnyNodable) -> Bool {
        fatalError()
    }
}
