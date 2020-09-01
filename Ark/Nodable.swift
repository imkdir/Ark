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


/// A SectionInfaltor provides items for a section
/// and act as section level element for diff processing.
public protocol SectionInflator: Nodable {
    var items: [AnyNodable] { get }
}

public protocol Nodable: Diffable, Equatable {

    var diffIdentifier: AnyHashable { get }
    
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock
    
    func sizeRange(in context: NodeContext) -> ASSizeRange
}

public extension Nodable {
    func sizeRange(in context: NodeContext) -> ASSizeRange {
        context.automaticDimension
    }
}

public extension SectionInflator {
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        fatalError("This methods should never be called on SectionInflator.")
    }
}
