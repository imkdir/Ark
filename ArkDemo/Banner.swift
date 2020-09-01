//
//  Banner.swift
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

final class Banner: NodeModel {

    let id: UUID
    let image: UIImage
    
    init(image: UIImage) {
        self.id = UUID()
        self.image = image
        super.init()
    }
    
    override var diffIdentifier: AnyHashable {
        id.uuidString
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Banner else {
            return false
        }
        return id == object.id
            && image == object.image
    }
    
    override func nodeBlock(with channel: NodeChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        return { Node(image: self.image) }
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
