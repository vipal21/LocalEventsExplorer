//
//  FavoriteListView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI
import MapKit

struct FavoriteListView: View {
    // Fix 1: Connect directly to your master source of truth instead of a separate isolated view model
    @Bindable var viewModel: ExploreViewModel

    // Fix 2: Dynamically filter favorite events directly from the shared master collection
    private var favoriteEvents: [Event] {
        viewModel.events.filter { $0.isFavourite }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && favoriteEvents.isEmpty {
                    ProgressView("Loading Favorites...")
                } else if favoriteEvents.isEmpty {
                    ContentUnavailableView(
                        "No Bookmarks",
                        systemImage: "bookmark.slash",
                        description: Text("Events you bookmark will appear here.")
                    )
                } else {
                    // Fix 3: Loop over your dynamic collection cleanly
                    List(favoriteEvents) { event in
                        EventRowCard(event: event, onSaveToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.toggleFavourite(for: event)
                            }
                        })
                        .background(
                            NavigationLink(
                                "",
                                destination: EventDetailView(event: event, onSaveToggle: {
                                    viewModel.toggleFavourite(for: event)
                                })
                            )
                            .opacity(0)
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

