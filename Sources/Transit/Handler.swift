//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func transformDocument(value: Any, withRegisteredHandlers registeredHandlers: [Handler]) throws -> Any {

    var context = Context(registeredHandlers: registeredHandlers, transformer: { context, value in try transform(value: value, context: &context) })

    return try context.transform(value: value)
}

func transform(value: Any, context: inout Context) throws -> Any {
    let value = try context.registeredHandlers.reduce(value, { array, handler in
        try handler.transform(value: array, context: &context)
    })


    if let array2 = value as? [Any] {
        return try array2.map({ item in
            return try transform(value: item, context: &context)
        })
    } else {
        return value
    }
}

public struct Context {
    let registeredHandlers: [Handler]
    var keywordCache: [String] = []
    let transformer: (inout Context, Any) throws -> Any

    mutating func transform(value: Any) throws -> Any {
        return try self.transformer(&self, value)
    }

    mutating func insertInCache(_ string: String) -> String {
        var keyToUse = string[...]
        if keyToUse.starts(with: "~:") {
            keyToUse.removeFirst(2)
        }
        if keyToUse.starts(with: "~$") {
            keyToUse.removeFirst(2)
        }
        if keyToUse.hasSuffix("?") {
            keyToUse.removeLast()
        }

        let sanitized = String(keyToUse)
        if keyToUse.count > 1 {
            keywordCache.append(sanitized)
        }
        return sanitized
    }

    func lookupKeyIndex(_ key: String) -> Int? {
        guard key.starts(with: "^") else { return nil }

        var lookupKey = key.dropFirst()
        guard lookupKey.count <= 2 else { return nil }
        if lookupKey.count == 1 {
            lookupKey.insert("0", at: lookupKey.startIndex)
        }
        let index = lookupKey
            .reversed()
            .enumerated()
            .reduce(0, { acc, el in
                acc + (Int(el.element.asciiValue ?? 0) - 48) * Int(pow(Double(44), Double(el.offset)))
            })
        return index
    }

    mutating func normalize(rawKey: String) throws -> String {
        if let index = lookupKeyIndex(rawKey) {
            if index < keywordCache.count {
                return keywordCache[index]
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The cache key '\(rawKey)', index \(index), could not be found."))
            }
        } else {
            return insertInCache(rawKey)
        }
    }

}

public protocol Handler {
    func transform(value: Any, context: inout Context) throws -> Any
}

