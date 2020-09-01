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

/// A struct implements `Nodable` provides
/// info to construct a texture node and
/// act as section or item level element for diff processing.
public protocol Nodable: Diffable, Equatable {

    var diffIdentifier: AnyHashable { get }
    
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock
    
    func sizeRange(in context: NodeContext) -> ASSizeRange
}

public extension Nodable {
    func sizeRange(in context: NodeContext) -> ASSizeRange {
        // default implemention for sizeRange that can handle most of the cases.
        context.automaticDimension
    }
}

public extension SectionInflator {
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        // This is a compromise to avoid creating too much protocols
        fatalError("This methods should never be called on SectionInflator.")
    }
}
