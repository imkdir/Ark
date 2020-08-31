//
//  ViewController.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 2020/8/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import Ark
import AsyncDisplayKit

final class ViewController: ASDKViewController<ASCollectionNode> {
    
    private lazy var dataSource = DiffableDataSource<HomeFeed>(collectionNode: node)
    
    private var sections: [HomeFeed] = [] {
        didSet {
            updateUI(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let node = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: node)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemGroupedBackground
        node.alwaysBounceVertical = true
        node.contentInset = UIEdgeInsets(top: 48, left: 10, bottom: 0, right: 10)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        fetchFeeds()
        updateUI()
    }
    
    @objc func refresh() {
        if case .banner? = self.sections.first {
            return
        }
        let banner = Banner(id: UUID(), image: UIImage(named: "banner")!)
        self.sections.insert(.banner(banner), at: 0)
        dismissBanner()
    }
    
    private func dismissBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.sections.remove(at: 0)
        })
    }
    
    private func fetchFeeds() {
        sections = [
            .articleFeed(.init(date: Date(), subjects: [
                .article(.init(id: UUID(), title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...")),
                .article(.init(id: UUID(), title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.")),
                .poll(.init(id: UUID(), title: "Who is the best programmer in the world?", options: ["Rob Pike": 2, "Dennis Ritchie": 3, "Kent Beck": 4], isVoted: false))
            ]))
        ]
    }
    
    private func updateUI(animated: Bool = false) {
        dataSource.apply(.init(sections: sections), animatingDifferences: animated, completion: nil)
    }
}
