//
//  DateFormat.swift
//  Ark
//
//  Created by Dwight CHENG on 8/27/20.
//  Copyright © 2020 Glow. All rights reserved.
//

import Foundation

public func string(format: String, _ date: Date) -> String {
    
    if let formatter = dateFormatters[format] {
        return formatter.string(from: date)
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        dateFormatters[format] = formatter
        return formatter.string(from: date)
    }
}

private var dateFormatters: [String: DateFormatter] = [:]
