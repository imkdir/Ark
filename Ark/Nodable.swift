//
//  NodeModel.swift
//  Ark
//
//  Created by Dwight CHENG on 8/26/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

public protocol SectionInflator: Nodable {
    var items: [AnyNodable] { get }
}

public protocol Nodable: Diffable, Equatable {

    var diffIdentifier: AnyHashable { get }
    
    func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock
    
    func sizeRange(in context: NodeContext) -> ASSizeRange
}

public extension Nodable {
    func sizeRange(in context: NodeContext) -> ASSizeRange {
        context.automaticDimension
    }
    
    func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        ASCellNode.init
    }
}
