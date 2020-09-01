//
//  BatchUpdates.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/9/1.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation

struct BatchUpdates {
    var itemInserts: [IndexPath] = []
    var itemDeletes: [IndexPath] = []
    var itemMoves: [MoveIndexPath] = []
}

struct MoveIndexPath {
    let from: IndexPath
    let to: IndexPath
}

extension IndexSet {
    func toIndexPaths(section: Int) -> [IndexPath] {
        map({ IndexPath(item: $0, section: section) })
    }
}

extension Array where Element == List.MoveIndex {
    func toIndexPaths(section: Int) -> [MoveIndexPath] {
        map({
            MoveIndexPath(
                from: IndexPath(item: $0.from, section: section),
                to: IndexPath(item: $0.to, section: section))
        })
    }
}
