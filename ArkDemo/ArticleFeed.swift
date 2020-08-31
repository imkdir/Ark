//
//  ArticleFeed.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import Ark
import AsyncDisplayKit

struct ArticleFeed: CollectionViewModel {
    let date: Date
    let subjects: [Subject]
    
    var diffIdentifier: AnyHashable { date }
    
    var items: [CollectionViewModel] {
        [SectionHeader(date: date)] + subjects
    }
    
    enum Subject: CollectionViewModel {
        case article(Article)
        case poll(Poll)
        
        var content: CollectionViewModel {
            switch self {
            case .article(let article):
                return article
            case .poll(let poll):
                return poll
            }
        }
        
        var diffIdentifier: AnyHashable {
            content.diffIdentifier
        }
        
        var viewBlock: ASCellNodeBlock {
            content.viewBlock
        }
        
        func sizeRange(in context: CollectionNodeContext) -> ASSizeRange {
            content.sizeRange(in: context)
        }
    }
    
    // MARK: - Article
    struct Article: CollectionViewModel {
        let id: UUID
        let title: String
        let preview: String
        
        var diffIdentifier: AnyHashable { id }
        
        var viewBlock: ASCellNodeBlock {
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
    
    struct Poll: CollectionViewModel {
        let id: UUID
        let title: String
        let options: [String:Int]
        let isVoted: Bool
        
        var totalCount: Int {
            options.reduce(0, { $0 + $1.value })
        }
        
        var diffIdentifier: AnyHashable { id.uuidString }
        
        var viewBlock: ASCellNodeBlock {
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

extension ArticleFeed.Subject: Equatable {}

extension ArticleFeed.Article: Equatable {}

extension ArticleFeed.Poll: Equatable {}
