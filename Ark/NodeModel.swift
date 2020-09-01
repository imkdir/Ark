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

public protocol SectionInflator: Diffable, Equatable {
    var items: [NodeModel] { get }
}

open class NodeModel: NSObject, Diffable {

    open var diffIdentifier: AnyHashable {
        self
    }
    
    open func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        ASCellNode.init
    }
    
    open func sizeRange(in context: NodeContext) -> ASSizeRange {
        context.automaticDimension
    }
}
