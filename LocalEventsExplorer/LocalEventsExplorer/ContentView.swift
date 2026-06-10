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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

@MainActor
@Observable
final class ContentViewModel {
    let container = NSPersistentContainer(name: "LocalEventExplorerDataModel")

    init(){
        checkCoreDataConnections()
        getDataFromFile()
        
    }
    var events: [Event] = []
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
    func getDataFromCoredata(){
        do {
            let request = EventEntity.fetchRequest()
            let entities = try self.container.viewContext.fetch(request)

            let data =  entities.map {
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
            print (data)
        } catch let error {
            print (error)
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
