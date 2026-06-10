//
//  ContentView.swift
//  MyEventApp
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI

struct MainTabBarView: View {
    @State private var selectedTab: Int = 0
    // Injected central master instance managing your entire tab hierarchy pipeline
    @State private var sharedExploreViewModel: ExploreViewModel

    /// Initializer Injection (DI Pattern)
    init(viewModel: ExploreViewModel) {
        // Correctly initialize the state property wrapper with the injected value
        _sharedExploreViewModel = State(wrappedValue: viewModel)
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(viewModel: sharedExploreViewModel)
                .tabItem {
                    Label("Explore", systemImage: "map")
                }
                .tag(0)
            AllEventsListView(viewModel: sharedExploreViewModel)
                .tabItem {
                    Label("All Events", systemImage: "calendar")
                }
                .tag(1)

            FavouriteListView(viewModel: sharedExploreViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

