//
//  NodeEvent.swift
//  Ark
//
//  Created by Dwight CHENG on 2020/8/31.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias NodeChannel = PublishSubject<NodeEvent>

public struct NodeEvent {
    public let model: NodeModel
    public let kind: Kind
    public let indexPath: IndexPath
    public let userInfo: [String: Any]
    
    public enum Kind {
        case selection, refresh, action, dismiss
    }
    
    public func on<T: NodeModel>(completion: (GenericNodeEvent<T>) -> Void) -> NodeEvent {
        GenericNodeEvent<T>(self).map(completion)
        return self
    }
}

public struct GenericNodeEvent<T: NodeModel> {
    public let model: T
    public let kind: NodeEvent.Kind
    public let indexPath: IndexPath
    public let userInfo: [String: Any]
    
    public init?(_ nodeEvent: NodeEvent) {
        guard let model = nodeEvent.model as? T else {
            return nil
        }
        self.model = model
        self.kind = nodeEvent.kind
        self.indexPath = nodeEvent.indexPath
        self.userInfo = nodeEvent.userInfo
    }
}
