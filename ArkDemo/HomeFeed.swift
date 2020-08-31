//
//  HomeFeed.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 8/26/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import Ark
import AsyncDisplayKit

enum HomeFeed {
    case banner(Banner)
    case articleFeed(ArticleFeed)
}

extension HomeFeed: CollectionViewModel {
    private var content: CollectionViewModel {
        switch self {
        case .banner(let banner):
            return banner
        case .articleFeed(let articleFeed):
            return articleFeed
        }
    }
    
    var diffIdentifier: AnyHashable {
        content.diffIdentifier
    }
    
    var items: [CollectionViewModel] {
        content.items
    }
}

extension HomeFeed: Equatable {}
