//
//  HomeFeed.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 8/26/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import Ark

enum HomeFeed: SectionInflator {
    
    case banner(Banner)
    case subjects(SubjectFeed)

    var diffIdentifier: AnyHashable {
        switch self {
        case .banner(let banner):
            return banner.diffIdentifier
        case .subjects(let feed):
            return feed.date
        }
    }
    
    var items: [AnyNodable] {
        switch self {
        case .banner(let banner):
            return [AnyNodable(banner)]
        case .subjects(let feed):
            var items: [AnyNodable] = feed.subjects.map(AnyNodable.init)
            items.insert(AnyNodable(SectionHeader(date: feed.date)), at: 0)
            return items
        }
    }
}
