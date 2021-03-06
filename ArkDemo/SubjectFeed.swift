//
//  SubjectFeed.swift
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

struct SubjectFeed {

    let date: Date
    let subjects: [Subject]
    
    enum Subject: Nodable {
        case article(Article)
        case poll(Poll)
        
        var diffIdentifier: AnyHashable {
            switch self {
            case .article(let article):
                return article.diffIdentifier
            case .poll(let poll):
                return poll.diffIdentifier
            }
        }
        
        func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
            switch self {
            case .article(let article):
                return article.nodeBlock(with: channel, indexPath: indexPath)
            case .poll(let poll):
                return poll.nodeBlock(with: channel, indexPath: indexPath)
            }
        }
    }
    
    // MARK: - Article
    struct Article: Nodable {
        let title: String
        let preview: String
        var read: Bool
        
        var diffIdentifier: AnyHashable { title }
        
        func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
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
                
                alpha = article.read ? 0.6 : 1.0
                
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
    
    struct Poll: Nodable {
        let title: String
        let options: [String:Int]
        let isVoted: Bool
        
        var totalCount: Int {
            options.reduce(0, { $0 + $1.value })
        }
        
        var diffIdentifier: AnyHashable { title }
        
        func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
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

extension SubjectFeed: Equatable {
    static func == (lhs: SubjectFeed, rhs: SubjectFeed) -> Bool {
        lhs.date == rhs.date &&
        lhs.subjects == rhs.subjects
    }
}
