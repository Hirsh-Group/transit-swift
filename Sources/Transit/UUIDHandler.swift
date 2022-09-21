//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct UUIDHandler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let string = value as? String else {
            return value
        }
        guard string.starts(with: "~u") else {
            return value
        }
        return String(string.dropFirst(2))
    }
}
