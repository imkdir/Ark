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

/// a `NodeEventChannel` is passed in each `Nodable`'s
/// `nodeBlock(channel:indexPath:)`, where struct implemented `Nodable`
/// can reference the channel and pass in events from created texture node.
public typealias NodeEventChannel = PublishSubject<NodeEvent>


/// A `DiffableDataSoure<Target>` requires a `Target` implements `SectionInflator`,
/// and reference a collectionNode, set itself as collectionNode's data source and delegate,
/// whenever a new snapshot is applied, it calls `performBatchUpdates` on the collectionNode
/// by diffing old and new snapshot's sections.
///
/// It also manage events from all nodes, whoever interests in the events can subscribe
/// to `rx.nodeEventChannel` and pass in a callback `(GenericNodeEvent<T:Nodable>) -> Void`,
/// and subscriber will receive future events comming from that source.
public class DiffableDataSource<Target: SectionInflator>: NSObject,
    ASCollectionDelegate & ASCollectionDataSource {
    public typealias Snapshot = DiffableDataSourceSnapshot<Target>
    
    public private(set) var snapshot: Snapshot!
    
    public private(set) weak var collectionNode: ASCollectionNode!
    fileprivate let rx_channel = NodeEventChannel()
    
    // MARK: - Designated Initializer
    
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init()
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
    }
    
    // MARK: - Interfaces
    
    public func apply(_ snapshot: Snapshot, animatingDifferences: Bool, completion: (() -> Void)?) {
        guard let oldSnapshot = self.snapshot else {
            start(with: snapshot)
            return
        }
        self.snapshot = snapshot
        
        let diffResult = List.diffing(oldArray: oldSnapshot.sections, newArray: snapshot.sections)
        
        let batchUpdates = diffResult.updates.reduce(into: BatchUpdates()) { result, section in
            let diffResult = List.diffing(
                oldArray: oldSnapshot.sections[section].items,
                newArray: snapshot.sections[section].items).forBatchUpdates()
            print(diffResult)
            result.itemDeletes += diffResult.deletes.toIndexPaths(section: section)
            result.itemInserts += diffResult.inserts.toIndexPaths(section: section)
            result.itemMoves += diffResult.moves.toIndexPaths(section: section)
        }
        
        collectionNode.performBatch(animated: animatingDifferences, updates: { [node = self.collectionNode] in
            
            for move in batchUpdates.itemMoves {
                node?.moveItem(at: move.from, to: move.to)
            }
            
            node?.deleteItems(at: batchUpdates.itemDeletes)
            node?.insertItems(at: batchUpdates.itemInserts)

            for move in diffResult.moves {
                node?.moveSection(move.from, toSection: move.to)
            }
            node?.deleteSections(diffResult.deletes)
            node?.insertSections(diffResult.inserts)
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
        let event = NodeEvent(model: item, action: .selection, indexPath: indexPath, userInfo: [:])
        rx_channel.onNext(event)
    }
}

// MARK: - Rx Extension

extension Reactive {
    
    public func nodeEventChannel<Model: SectionInflator, T: Nodable>() -> Observable<GenericNodeEvent<T>>
        where Base: DiffableDataSource<Model> {
        base.rx_channel
            .asObserver()
            .compactMap(GenericNodeEvent<T>.init)
            .observeOn(MainScheduler.instance)
    }
}
