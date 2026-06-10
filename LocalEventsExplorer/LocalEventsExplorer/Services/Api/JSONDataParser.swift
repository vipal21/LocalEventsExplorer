//
//  JSONDataParser.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import Foundation

/// A fully generic data parser capable of processing any Codable types.
struct JSONDataParser: Sendable {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    /// Decodes raw data into any specified type conforming to Decodable.
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw EventError.decodeError
        }
    }
    /// Encodes any specified type conforming to Encodable into raw data.
    func encode<T: Encodable>(_ value: T) throws -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw EventError.decodeError
        }
    }
}
