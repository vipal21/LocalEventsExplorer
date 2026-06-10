//
//  EventError.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//
import Foundation

// MARK: - Event Errors
enum EventError: Error, LocalizedError {
    case invalidURL
    case noInternetorTimeout
    case serverError(statusCode: Int)
    case decodeError
    case unknown(Error)
    /// User-friendly messages perfectly suited for a Toast or Alert UI
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Internal error: The server address was configured incorrectly."
        case .noInternetorTimeout:
            return "Connection lost. Please check your internet and try again."
        case .serverError(let statusCode):
            return "The server responded with an error (Code: \(statusCode)). Please try again later."
        case .decodeError:
            return "We encountered an issue reading the data. Please ensure your app is updated."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
