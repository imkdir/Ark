//
//  CollectionViewModel.swift
//  Ark
//
//  Created by Dwight CHENG on 8/26/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public protocol CollectionViewModel: Diffable {
    
    var items: [CollectionViewModel] { get }
    
    var viewBlock: ASCellNodeBlock { get }
    
    func sizeRange(in context: CollectionNodeContext) -> ASSizeRange
}

// MARK: -  Default Implementation for Single Item Section

public extension CollectionViewModel {
    
    var items: [CollectionViewModel] {
        [self]
    }
    
    var viewBlock: ASCellNodeBlock {
        ASCellNode.init
    }
    
    func sizeRange(in context: CollectionNodeContext) -> ASSizeRange {
        context.automaticDimension
    }
}
