//
//  Event.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-09.
//

import Foundation

struct Event: Codable, Equatable, Identifiable, Hashable {
    let id: Int64
    let title, venue: String
    let venueImage: String
    let eventDescription: String
    let eventImages: [String]
    let date: String
    let startTime: String
    let endTime: String
    let latitude, longitude: Double
    let isFavourite: Bool
    var distanceFromUser: String?
}
extension Event {
    /// Converts an ISO-8601 backend date string into a localized, human-readable display string
    var formattedDateDisplay: String {
        // 1. Initialize modern built-in formatter options matching your string matrix
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        // 2. Fallback strategy if your backend data omits timezone specifiers (e.g. trailing 'Z')
        if let parsedDate = isoFormatter.date(from: date) {
            return parsedDate.formatted(date: .long, time: .omitted)
        }

        // 3. Secondary parser fallback for fractional or local non-Z timestamps
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        localFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let alternativeDate = localFormatter.date(from: date) else {
            return date // Final safety fallback returns the raw string if all decoding options fail
        }

        return alternativeDate.formatted(date: .long, time: .omitted)
    }
}
