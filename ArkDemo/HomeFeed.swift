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

enum HomeFeed: SectionInflator {
    case banner(Banner)
    case articleFeed(ArticleFeed)

    var diffIdentifier: AnyHashable {
        switch self {
        case .banner(let banner):
            return banner.diffIdentifier
        case .articleFeed(let feed):
            return feed.date
        }
    }
    
    var items: [NodeModel] {
        switch self {
        case .banner(let banner):
            return [banner]
        case .articleFeed(let feed):
            var result: [NodeModel] = feed.subjects
            result.insert(SectionHeader(date: feed.date), at: 0)
            return result
        }
    }
}
