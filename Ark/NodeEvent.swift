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

public struct NodeEvent {
    public let model: AnyNodable
    public let action: Action
    public let indexPath: IndexPath
    
    public enum Action {
        // Collection Node Delegate Events
        case didSelect
        case didDeselect
        case didHighlight
        case didUnhighlight
        case willDisplay
        case endDisplay
        
        // Custom Node General Events
        case ok(info: [String:Any])
        case cancel
    }
}

public struct GenericNodeEvent<T: Nodable> {
    public let model: T
    public let action: NodeEvent.Action
    public let indexPath: IndexPath
    
    public init?(_ nodeEvent: NodeEvent) {
        guard let model = nodeEvent.model.base as? T else {
            return nil
        }
        self.model = model
        self.action = nodeEvent.action
        self.indexPath = nodeEvent.indexPath
    }
}
