//
//  OnlineEventService.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

protocol EventServiceProtocol: Sendable {
    func fetchEvents() async throws -> [Event]
}
final class OnlineEventService: EventServiceProtocol {
    private let client: APIClient
    private let coreDataManager: CoreDataManager
    // Replace with your real API endpoint when ready
    private let urlString = "https://jsonplaceholder.typicode.com/photos"
    // Inject our generic engine
    init(
        client: APIClient = APIClient(),
        coreDataManager: CoreDataManager = .shared
    ) {
        self.client = client
        self.coreDataManager = coreDataManager
    }
    //    func fetchEvents() async throws -> [Event] {
    //        // The generic client handles the network call and decodes straight into [Event]
    //        return try await client.fetch([Event].self, from: urlString)
    //    }
    func fetchEvents() async throws -> [Event] {
        print("📱 Fetching local event data from Core Data...")
        let localEvents = try await coreDataManager.fetchEvents()
        print("📦 Local Core Data event count: \(localEvents.count)")
        print("🌐 Calling Event API...")
        let apiEvents = try await client.fetch([Event].self, from: urlString)
        print("✅ API event response count: \(apiEvents.count)")
        // Create a dictionary map of existing favorite statuses stored locally on device
        let localFavoritesMap = Dictionary(uniqueKeysWithValues: localEvents.map { ($0.id, $0.isFavourite) })
        // Map the incoming network array to preserve what the user already favorited locally
        let apiEventsPreservingFavorites = apiEvents.map { networkEvent in
            Event(
                id: networkEvent.id,
                title: networkEvent.title,
                venue: networkEvent.venue,
                venueImage: networkEvent.venueImage,
                eventDescription: networkEvent.eventDescription,
                eventImages: networkEvent.eventImages,
                date: networkEvent.date,
                startTime: networkEvent.startTime,
                endTime: networkEvent.endTime,
                latitude: networkEvent.latitude,
                longitude: networkEvent.longitude,
                isFavourite: localFavoritesMap[networkEvent.id] ?? false // Keep local status or default to false
            )
        }
        // Sort arrays safely for direct equivalence checks
        let sortedAPIEvents = apiEventsPreservingFavorites.sorted { $0.id < $1.id }
        let sortedLocalEvents = localEvents.sorted { $0.id < $1.id }
        // Now this comparison evaluates properties cleanly without accidental resets
        if sortedAPIEvents != sortedLocalEvents {
            print("🔄 Actual server data payload changed! Updating Core Data...")
            try await coreDataManager.deleteAllEvents()
            // Save the updated list that preserves existing favorites
            try await coreDataManager.saveEvents(apiEventsPreservingFavorites)
            return sortedAPIEvents
        } else {
            print("✅ API events and Core Data events are identical")
            return sortedLocalEvents
        }
    }
}
