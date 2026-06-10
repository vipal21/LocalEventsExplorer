//
//  ContentView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI
import Foundation
import CoreData

struct ContentView: View {
    private let viewModel = ContentViewModel()
    var body: some View {
        VStack {
            List(viewModel.events) { event in
                HStack{
                    Text(event.title)
                    Button("Save") {
                        viewModel.toggleFavourite(for: event)
                    }
                    Button("FavList") {
                        viewModel.getDataFavourite()
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

@MainActor
@Observable
final class ContentViewModel {
    let container = NSPersistentContainer(name: "LocalEventExplorerDataModel")
    var events:[Event] = []
    init(){
        checkCoreDataConnections()
        getDataFromFile()
        
    }
    func getDataFromFile (){

        guard let url = Bundle.main.url(forResource: "eventList", withExtension: "json") else {
           return
        }
        do {
              let data2 = try Data(contentsOf: url)
            let reult =   try JSONDecoder().decode([Event].self, from: data2)
            saveDatainCoreData(events: reult)
            getDataFromCoredata()


        } catch let error {
            print(error.localizedDescription)
        }


    }
    func saveDatainCoreData(events:[Event]) {
        do {
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
        } catch let error {
            print (error)
        }

    }
    func toggleFavourite(for event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        let newStatus = !events[index].isFavourite

        events[index] = Event(
            id: event.id, title: event.title, venue: event.venue, venueImage: event.venueImage,
            eventDescription: event.eventDescription, eventImages: event.eventImages,
            date: event.date, startTime: event.startTime, endTime: event.endTime,
            latitude: event.latitude, longitude: event.longitude, isFavourite: newStatus,
            distanceFromUser: events[index].distanceFromUser
        )

        Task {
            try? await self.updateFavouriteStatus(eventID: event.id, isFavourite: newStatus)
        }
    }
    func getDataFromCoredata(){
        do {
            let request = EventEntity.fetchRequest()
            let entities = try self.container.viewContext.fetch(request)

            events =  entities.map {
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
        } catch let error {
            print (error)
        }




    }
    func getDataFavourite(){
        do {
            let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
            let entities = try self.container.viewContext.fetch(request)

            events =  entities.map {
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
        } catch let error {
            print (error)
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
                print("💾 Core Data favorite status updated for ID \(eventID): \(isFavourite)")
            }
        }
    }
    func checkCoreDataConnections(){
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data error:", error)
            }
            print("Core Data connected")
        }
    }

}


#Preview {
    ContentView()
}
