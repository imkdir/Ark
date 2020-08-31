//
//  ASSizeRangeExtension.swift
//  Ark
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import AsyncDisplayKit

public extension ASSizeRange {
    
    static func automaticSize(width: CGFloat) -> ASSizeRange {
        return ASSizeRange(
            min: .init(width: width, height: .leastNonzeroMagnitude),
            max: .init(width: width, height: .greatestFiniteMagnitude))
    }
}
