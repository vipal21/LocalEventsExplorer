//
//  LocalEventsExplorerApp.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI

@main
struct LocalEventsExplorerApp: App {
    // 1. Initialize your business infrastructure layer safely on the Main Actor
    @State private var productionViewModel: ExploreViewModel

    init() {
        let liveService = OnlineEventService()
        _productionViewModel = State(wrappedValue: ExploreViewModel(service: liveService))
    }

    var body: some Scene {
        WindowGroup {
            // 2. Inject the configured view model directly into your root tab container view
            MainTabBarView(viewModel: productionViewModel)
        }
    }
}
