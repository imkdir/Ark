//
//  ArticleFeed.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import Ark
import RxSwift
import RxCocoa
import AsyncDisplayKit

struct ArticleFeed {

    let date: Date
    let subjects: [Subject]
    
    final class Subject: NodeModel {
        
        enum _Subject: Equatable {
            case article(Article)
            case poll(Poll)
        }
        
        private var _subject: _Subject
        
        init(article: Article) {
            self._subject = .article(article)
            super.init()
        }
        
        init(poll: Poll) {
            self._subject = .poll(poll)
            super.init()
        }
        
        override var diffIdentifier: AnyHashable {
            switch _subject {
            case .article(let article):
                return article.diffIdentifier
            case .poll(let poll):
                return poll.diffIdentifier
            }
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Subject else {
                return false
            }
            return self._subject == object._subject
        }
        
        override func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
            switch _subject {
            case .article(let article):
                return article.nodeBlock(with: channel, indexPath: indexPath)
            case .poll(let poll):
                return poll.nodeBlock(with: channel, indexPath: indexPath)
            }
        }
        
        override func sizeRange(in context: NodeContext) -> ASSizeRange {
            context.automaticDimension
        }
    }
    
    // MARK: - Article
    final class Article: NodeModel {
        let id: UUID
        let title: String
        let preview: String
        
        init(title: String, preview: String) {
            self.id = UUID()
            self.title = title
            self.preview = preview
            super.init()
        }
        
        override var diffIdentifier: AnyHashable { id }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Article else {
                return false
            }
            return id == object.id
                && title == object.title
                && preview == object.preview
        }
        
        override func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
            return { Node(article: self) }
        }
        
        final class Node: ASCellNode {
            var titleNode: ASTextNode
            var previewNode: ASTextNode
        
            init(article: Article) {
                self.titleNode = ASTextNode()
                self.previewNode = ASTextNode()
                super.init()
                
                automaticallyManagesSubnodes = true
                backgroundColor = .systemBackground
                
                titleNode.attributedText = NSAttributedString(
                    string: article.title,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                        .foregroundColor: UIColor.label])
                
                previewNode.attributedText = NSAttributedString(
                    string: article.preview,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15),
                        .foregroundColor: UIColor.secondaryLabel])
            }
            
            override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
                let stack = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 4,
                    justifyContent: .spaceBetween,
                    alignItems: .stretch,
                    children: [titleNode, previewNode])
                
                return ASInsetLayoutSpec(insets: .init(top: 8, left: 15, bottom: 8, right: 15), child: stack)
            }
        }
    }
    
    final class Poll: NodeModel {
        let id: UUID
        let title: String
        let options: [String:Int]
        let isVoted: Bool
        
        init(title: String, options: [String:Int], isVoted: Bool) {
            self.id = UUID()
            self.title = title
            self.options = options
            self.isVoted = isVoted
            super.init()
        }
        
        var totalCount: Int {
            options.reduce(0, { $0 + $1.value })
        }
        
        override var diffIdentifier: AnyHashable { id.uuidString }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Poll else {
                return false
            }
            return id == object.id
                && title == object.title
                && options == object.options
                && isVoted == object.isVoted
        }
        
        override func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
            return { Node(poll: self) }
        }
        
        final class Node: ASCellNode {
            var titleNode: ASTextNode
            var optionNodes: [ASDisplayNode]
            
            init(poll: Poll) {
                self.titleNode = ASTextNode()
                
                self.optionNodes = poll.options
                    .map({
                        let value = CGFloat($0.value) / CGFloat(poll.totalCount)
                        return BarNode(title: $0.key, value: value)
                    })
                
                super.init()
                
                automaticallyManagesSubnodes = true
                backgroundColor = .systemBackground
                
                titleNode.attributedText = NSAttributedString(
                    string: poll.title,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                        .foregroundColor: UIColor.label])
            }
            
            override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
                let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
                return ASInsetLayoutSpec(
                    insets: insets,
                    child: ASStackLayoutSpec(
                        direction: .vertical,
                        spacing: 4,
                        justifyContent: .spaceBetween,
                        alignItems: .stretch,
                        children: [titleNode] + optionNodes))
            }
            
            final class BarNode: ASDisplayNode {
                var frontNode: ASDisplayNode
                var titleNode: ASTextNode
                
                init(title: String, value: CGFloat) {
                    self.frontNode = ASDisplayNode()
                    self.titleNode = ASTextNode()
                    
                    super.init()
                    
                    automaticallyManagesSubnodes = true
                    style.height = ASDimensionMake(30)
                    
                    backgroundColor = UIColor.systemGray6
                    cornerRadius = 4
                    
                    frontNode.backgroundColor = UIColor.systemBlue
                    frontNode.style.width = ASDimensionMake(UIScreen.main.bounds.width * value)
                    frontNode.cornerRadius = 4

                    titleNode.attributedText = NSAttributedString(
                        string: title,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor.white])
                }
                
                override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
                    let overlaySpec = ASOverlayLayoutSpec(child: frontNode, overlay: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode))
                    
                    let relativeSpec = ASRelativeLayoutSpec(
                        horizontalPosition: .start,
                        verticalPosition: .start,
                        sizingOption: [],
                        child: overlaySpec)
                    
                    return relativeSpec
                }
            }
        }
    }
}

extension ArticleFeed: Equatable {
    static func == (lhs: ArticleFeed, rhs: ArticleFeed) -> Bool {
        lhs.date == rhs.date &&
        lhs.subjects == rhs.subjects
    }
}
