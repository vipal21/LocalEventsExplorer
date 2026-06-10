//
//  AllEventsListView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI

import SwiftUI
import MapKit

struct AllEventsListView: View {
    // Fix 1: Connect directly to your central source of truth instead of an isolated local state instance
    @Bindable var viewModel: ExploreViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView("Loading Events...")
                } else if viewModel.events.isEmpty {
                    ContentUnavailableView(
                        "No Events Found",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Check back later for new updates.")
                    )
                } else {
                    List(viewModel.events) { event in
                        EventRowCard(event: event, onSaveToggle: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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
            .navigationTitle("All Events")
        }
    }
}
