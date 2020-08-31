//
//  CollectionViewContext.swift
//  GLFeedKit
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit

public struct CollectionViewContext {
    let section: CollectionViewModel
    let containerSize: CGSize
    let contentInset: UIEdgeInsets
    
    var widthThatFit: CGFloat {
        max(0, containerSize.width - contentInset.left - contentInset.right)
    }
}
