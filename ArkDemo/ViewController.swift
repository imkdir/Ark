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
        let dateMinusDayCount = {
            Date().addingTimeInterval(-86400 * $0)
        }
        sections = [
            .subjects(.init(date: dateMinusDayCount(0), subjects: [
                .article(.init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...", read: false)),
                .article(.init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.", read: false)),
                .poll(.init(title: "Who is the best programmer in the world?", options: ["Rob Pike": 2, "Dennis Ritchie": 3, "Kent Beck": 4], isVoted: false))
            ])),
            .subjects(.init(date: dateMinusDayCount(1), subjects: [
                .article(.init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...", read: false)),
                .article(.init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.", read: false)),
                .poll(.init(title: "Which Game you played most on Nintendo Switch?", options: ["Clubhouse Games": 32, "Super Smash Bros": 28, "Fitness Boxing": 30], isVoted: false))
            ])),
            .subjects(.init(date: dateMinusDayCount(2), subjects: [
                .article(.init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...", read: false)),
                .article(.init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.", read: false)),
                .poll(.init(title: "Who is your favorite Beatle?", options: ["Paul McCartney": 12, "John Lennon": 8, "George Harrison": 11, "Ringo Starr": 22], isVoted: false))
            ])),
            .subjects(.init(date: dateMinusDayCount(3), subjects: [
                .article(.init(title: "Lorem ipsum dolor sit amet.", preview: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...", read: false)),
                .article(.init(title: "Morbi neque ex, rhoncus nec.", preview: "In vel mauris ullamcorper. Donec interdum magna felis, sed ultrices magna interdum eu.", read: false)),
                .poll(.init(title: "Which is the Best Show on Nextflix?", options: ["The Office": 7, "Avatar: The Last Airbender": 15, "Line of Duty": 8], isVoted: false))
            ]))
        ]
    }
    
    private func updateUI(animated: Bool = false) {
        dataSource.apply(.init(sections: sections), animatingDifferences: animated, completion: nil)
    }
    
    private func observeEvents() {
        dataSource
            .rx.nodeEventChannel()
            .subscribe(onNext: handleSubjectEvent)
            .disposed(by: disposeBag)
        
        dataSource
            .rx.nodeEventChannel()
            .subscribe(onNext: handleBannerEvent)
            .disposed(by: disposeBag)
        
        dataSource
            .rx.nodeEventChannel()
            .subscribe(onNext: { (event: GenericNodeEvent<SectionHeader>) in
                print("\(event.action) \(event.model)")
            })
            .disposed(by: disposeBag)
    }
    
    private func handleSubjectEvent(_ event: GenericNodeEvent<SubjectFeed.Subject>) {
        guard case .subjects(let feed) = sections[event.indexPath.section],
            let index = feed.subjects.firstIndex(of: event.model) else {
            return
        }
        switch event.action {
        case .didSelect:
            var subjects = feed.subjects
            subjects.remove(at: index)
            subjects.append(event.model)
            let newFeed = HomeFeed.subjects(.init(date: feed.date, subjects: subjects))
            sections[event.indexPath.section] = newFeed
        default:
            break
        }
    }
    
    private func handleBannerEvent(_ event: GenericNodeEvent<Banner>) {
        switch event.action {
        case .didSelect:
            sections.removeAll(where: { section in
                guard case .banner(let banner) = section else {
                    return false
                }
                return banner == event.model
            })
        default:
            break
        }
    }
    
    private let disposeBag = DisposeBag()
}
