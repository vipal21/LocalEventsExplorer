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
