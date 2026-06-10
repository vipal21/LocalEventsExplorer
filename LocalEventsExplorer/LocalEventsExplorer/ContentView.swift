//
//  ContentView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI
import Foundation

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
    init(){
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
             print(reult.count)
        } catch let error {
            print(error.localizedDescription)
        }


    }
}


#Preview {
    ContentView()
}
