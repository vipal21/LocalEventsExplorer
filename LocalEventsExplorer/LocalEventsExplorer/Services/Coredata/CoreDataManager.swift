//
//  CoreDataManager.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import Foundation
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "LocalEventExplorerDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data error:", error)
            }
        }
    }

    func fetchEvents() async throws -> [Event] {
        try await container.viewContext.perform {
            let request = EventEntity.fetchRequest()
            let entities = try self.container.viewContext.fetch(request)

            return entities.map {
                Event(
                    id: $0.id,
                    title: $0.title ?? "",
                    venue: $0.venue ?? "",
                    venueImage: $0.venueImage ?? "",
                    eventDescription: $0.eventDescription ?? "",
                    eventImages: ($0.eventImages ?? "").components(separatedBy: ","),
                    date: $0.date ?? "",
                    startTime: $0.startTime ?? "",
                    endTime: $0.endTime ?? "",
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    isFavourite: $0.isFavourite
                )
            }
        }
    }

    func saveEvents(_ events: [Event]) async throws {
        try await container.viewContext.perform {
            for event in events {
                let entity = EventEntity(context: self.container.viewContext)

                entity.id = Int64(event.id)
                entity.title = event.title
                entity.venue = event.venue
                entity.venueImage = event.venueImage
                entity.eventDescription = event.eventDescription
                entity.eventImages = event.eventImages.joined(separator: ",")
                entity.date = event.date
                entity.startTime = event.startTime
                entity.endTime = event.endTime
                entity.latitude = event.latitude
                entity.longitude = event.longitude
                entity.isFavourite = event.isFavourite
            }

            try self.container.viewContext.save()
        }
    }

    func deleteAllEvents() async throws {
        try await container.viewContext.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = EventEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try self.container.viewContext.execute(deleteRequest)
            try self.container.viewContext.save()
        }
    }
    func updateFavouriteStatus(eventID: Int64, isFavourite: Bool) async throws {
        try await container.viewContext.perform {
            let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
            // Pass the Int64 directly into the predicate
            request.predicate = NSPredicate(format: "id == %lld", eventID)
            request.fetchLimit = 1

            if let event = try self.container.viewContext.fetch(request).first {
                event.isFavourite = isFavourite
                try self.container.viewContext.save()
                print("💾 Core Data favourite status updated for ID \(eventID): \(isFavourite)")
            }
        }
    }
    func fetchFavouriteEvents() async throws -> [Event] {
        try await container.viewContext.perform {

            let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))

            let entities = try self.container.viewContext.fetch(request)

            return entities.map {
                Event(
                    id: $0.id,
                    title: $0.title ?? "",
                    venue: $0.venue ?? "",
                    venueImage: $0.venueImage ?? "",
                    eventDescription: $0.eventDescription ?? "",
                    eventImages: ($0.eventImages ?? "").components(separatedBy: ","),
                    date: $0.date ?? "",
                    startTime: $0.startTime ?? "",
                    endTime: $0.endTime ?? "",
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    isFavourite: $0.isFavourite
                )
            }
        }
    }
}
