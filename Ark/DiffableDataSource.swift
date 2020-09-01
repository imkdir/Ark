//
//  DiffableDataSource.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/8/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit


public struct DiffableDataSourceSnapshot<T: SectionInflator> {
    public private(set) var sections: [T]
    
    public init(sections: [T]) {
        self.sections = sections
    }
    
    public func item(for indexPath: IndexPath) -> AnyNodable {
        sections[indexPath.section].items[indexPath.item]
    }
    
    public func numberOfItems(in section: Int) -> Int {
        sections[section].items.count
    }
}

public class DiffableDataSource<Target: SectionInflator>: NSObject,
    ASCollectionDelegate & ASCollectionDataSource {
    public typealias Snapshot = DiffableDataSourceSnapshot<Target>
    
    public private(set) var snapshot: Snapshot!
    
    public private(set) weak var collectionNode: ASCollectionNode!
    fileprivate let rx_channel = NodeChannel()
    
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
        return item.nodeBlock(with: rx_channel, indexPath: indexPath)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let item = snapshot.item(for: indexPath)
        let context = NodeContext(
            containerSize: collectionNode.calculatedSize,
            contentInset: collectionNode.contentInset)
        return item.sizeRange(in: context)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let item = snapshot.item(for: indexPath)
        let event = NodeEvent(model: item, kind: .selection, indexPath: indexPath, userInfo: [:])
        rx_channel.onNext(event)
    }
}

extension Reactive {
    
    public func nodeEventChannel<Model: SectionInflator, T: Nodable>() -> Observable<GenericNodeEvent<T>>
        where Base: DiffableDataSource<Model> {
        base.rx_channel
            .asObserver()
            .debug("NodeEvent")
            .compactMap(GenericNodeEvent<T>.init)
            .observeOn(MainScheduler.instance)
    }
}
