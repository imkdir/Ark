//
//  DiffableDataSource.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/8/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import AsyncDisplayKit


public struct DiffableDataSourceSnapshot<T: CollectionViewModel> {
    public private(set) var sections: [T]
    
    public init(sections: [T]) {
        self.sections = sections
    }
    
    public func item(for indexPath: IndexPath) -> CollectionViewModel {
        sections[indexPath.section].items[indexPath.item]
    }
    
    public func numberOfItems(in section: Int) -> Int {
        sections[section].items.count
    }
}

public class DiffableDataSource<Model: CollectionViewModel & Equatable>: NSObject,
    ASCollectionDelegate & ASCollectionDataSource {
    public typealias Snapshot = DiffableDataSourceSnapshot<Model>
    
    public private(set) var snapshot: Snapshot!
    
    public private(set) weak var collectionNode: ASCollectionNode!
    
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init()
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
    }
    
    public func apply(_ snapshot: Snapshot, animatingDifferences: Bool, completion: (() -> Void)?) {
        guard let oldSnapshot = self.snapshot else {
            start(with: snapshot)
            return
        }
        self.snapshot = snapshot
        let result = List.diffing(oldArray: oldSnapshot.sections, newArray: snapshot.sections).forBatchUpdates()
        // TODO: combine diff result with requested index paths updates
        collectionNode.performBatch(animated: animatingDifferences, updates: { [node = self.collectionNode] in
            for move in result.moves {
                node?.moveSection(move.from, toSection: move.to)
            }
            node?.deleteSections(result.deletes)
            node?.insertSections(result.inserts)
        })
    }
    
    public func start(with snapshot: Snapshot) {
        self.snapshot = snapshot
        collectionNode.reloadData()
    }
    
    // MARK: CollectionNode Data Source & Delegate
    
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        snapshot?.sections.count ?? 0
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        snapshot.numberOfItems(in: section)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let item = snapshot.item(for: indexPath)
        return item.viewBlock
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let section = snapshot.sections[indexPath.section]
        let item = snapshot.item(for: indexPath)
        let context = CollectionNodeContext(
            section: section,
            containerSize: collectionNode.calculatedSize,
            contentInset: collectionNode.contentInset)
        return item.sizeRange(in: context)
    }
}
