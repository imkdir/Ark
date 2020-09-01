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
        
        setupViews()
        fetchFeeds()
        updateUI()
        observeEvents()
    }
    
    private func setupViews() {
        node.backgroundColor = .systemGroupedBackground
        node.alwaysBounceVertical = true
        node.contentInset = UIEdgeInsets(top: 48, left: 10, bottom: 0, right: 10)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
    
    @objc func refresh() {
        if case .banner? = self.sections.first {
            return
        }
        let banner = Banner(imageName: "banner")
        self.sections.insert(.banner(banner), at: 0)
    }
    
    private func fetchFeeds() {
        sections = [
            .articleFeed(.init(date: Date(), subjects: [
                .article(.init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...", read: false)),
                .article(.init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.", read: false)),
                .poll(.init(title: "Who is the best programmer in the world?", options: ["Rob Pike": 2, "Dennis Ritchie": 3, "Kent Beck": 4], isVoted: false))
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
        func findSectionAndIndex(of subject: ArticleFeed.Subject) -> (ArticleFeed, IndexPath)? {
            for (section, model) in self.sections.enumerated() {
                guard case .articleFeed(let feed) = model,
                    let index = feed.subjects.firstIndex(of: subject) else {
                    continue
                }
                return (feed, IndexPath(item: index, section: section))
            }
            return nil
        }
        if let (feed, indexPath) = findSectionAndIndex(of: event.model) {
            switch event.model {
            case .article(var article):
                article.read.toggle()
                var subjects = feed.subjects
                subjects[indexPath.item] = .article(article)
                let newFeed = HomeFeed.articleFeed(.init(date: feed.date, subjects: subjects))
                sections[indexPath.section] = newFeed
            case .poll(let poll):
                break
            }
        }
    }
    
    private func handleBannerEvent(_ event: GenericNodeEvent<Banner>) {
        sections.removeAll(where: { section in
            guard case .banner(let banner) = section else {
                return false
            }
            return banner == event.model
        })
    }
    
    private let disposeBag = DisposeBag()
}
