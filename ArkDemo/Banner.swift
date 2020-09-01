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

struct Banner: Nodable {

    let imageName: String
    
    var diffIdentifier: AnyHashable {
        imageName
    }
    
    func nodeBlock(with channel: NodeEventChannel, indexPath: IndexPath) -> ASCellNodeBlock {
        let image = UIImage(named: imageName)!
        return { Node(image: image) }
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
