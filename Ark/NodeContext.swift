//
//  NodeContext.swift
//  Ark
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import AsyncDisplayKit


public struct NodeContext {
    public let containerSize: CGSize
    public let contentInset: UIEdgeInsets
    
    public var automaticDimension: ASSizeRange {
        ASSizeRange.automaticSize(width: contentWidth)
    }
    
    public var contentWidth: CGFloat {
        max(0, containerSize.width - contentInset.left - contentInset.right)
    }
    
    public func sizeRange(height: CGFloat) -> ASSizeRange {
        ASSizeRangeMake(.init(width: contentWidth, height: height))
    }
}

public extension ASSizeRange {
    
    static func automaticSize(width: CGFloat) -> ASSizeRange {
        return ASSizeRange(
            min: .init(width: width, height: .leastNonzeroMagnitude),
            max: .init(width: width, height: .greatestFiniteMagnitude))
    }
}
