//
//  SectionHeader.swift
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


struct SectionHeader: Nodable {
    let date: Date
    
    var diffIdentifier: AnyHashable { date }
    
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        return { [description] in Node(title: description) }
    }
    
    func sizeRange(in context: NodeContext) -> ASSizeRange {
        context.sizeRange(height: 35)
    }
    
    final class Node: ASCellNode {
        var titleNode: ASTextNode
        
        init(title: String) {
            self.titleNode = ASTextNode()
            super.init()
            automaticallyManagesSubnodes = true
            
            titleNode.attributedText = NSAttributedString(
                string: title,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.label])
        }
        
        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            ASInsetLayoutSpec(
                insets: .init(top: 4, left: 15, bottom: 4, right: 15),
                child: titleNode)
        }
    }
}

extension SectionHeader: CustomStringConvertible {
    var description: String {
        string(format: "MMM dd", self.date)
    }
}
