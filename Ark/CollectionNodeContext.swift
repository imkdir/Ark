//
//  CollectionNodeContext.swift
//  Ark
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit

public struct CollectionNodeContext {
    public let section: CollectionViewModel
    public let containerSize: CGSize
    public let contentInset: UIEdgeInsets
    
    public var widthThatFit: CGFloat {
        max(0, containerSize.width - contentInset.left - contentInset.right)
    }
}
