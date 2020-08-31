//
//  Banner.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import Ark
import AsyncDisplayKit

struct Banner: CollectionViewModel {
    let id: UUID
    let image: UIImage
    
    var diffIdentifier: AnyHashable { id.uuidString }
    
    var viewBlock: ASCellNodeBlock {
        return { Node(image: self.image) }
    }
    
    func onSelected() {
        
    }
    
    final class Node: ASCellNode {
        var imageNode: ASImageNode
        
        init(image: UIImage) {
            self.imageNode = ASImageNode()
            
            super.init()
            
            automaticallyManagesSubnodes = true
            backgroundColor = .systemBackground
            
            imageNode.image = image
            imageNode.cornerRadius = 4
            imageNode.contentMode = .scaleAspectFit
        }
        
        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            ASWrapperLayoutSpec(layoutElement: imageNode)
        }
    }
}

extension Banner: Equatable {}
