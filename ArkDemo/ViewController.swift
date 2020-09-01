//
//  ViewController.swift
//  ArkDemo
//
//  Created by Dwight CHENG on 2020/8/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import UIKit
import Ark
import RxSwift
import RxCocoa
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
        observeEvents()
    }
    
    @objc func refresh() {
        if case .banner? = self.sections.first {
            return
        }
        let banner = Banner(image: UIImage(named: "banner")!)
        self.sections.insert(.banner(banner), at: 0)
    }
    
    private func dismissBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.sections.remove(at: 0)
        })
    }
    
    private func fetchFeeds() {
        sections = [
            .articleFeed(.init(date: Date(), subjects: [
                .init(article: .init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...")),
                .init(article: .init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.")),
                .init(poll: .init(title: "Who is the best programmer in the world?", options: ["Rob Pike": 2, "Dennis Ritchie": 3, "Kent Beck": 4], isVoted: false))
            ]))
        ]
    }
    
    private func updateUI(animated: Bool = false) {
        dataSource.apply(.init(sections: sections), animatingDifferences: animated, completion: nil)
    }
    
    private func observeEvents() {
        dataSource
            .rx.nodeEventChannel()
            .debug("ArticleFeed")
            .subscribe(onNext: handleArticleEvent)
            .disposed(by: disposeBag)
        
        dataSource
            .rx.nodeEventChannel()
            .debug("Banner")
            .subscribe(onNext: handleBannerEvent)
            .disposed(by: disposeBag)
    }
    
    private func handleArticleEvent(_ event: GenericNodeEvent<ArticleFeed.Subject>) {
        
    }
    
    private func handleBannerEvent(_ event: GenericNodeEvent<Banner>) {
        
    }
    
    private let disposeBag = DisposeBag()
}
