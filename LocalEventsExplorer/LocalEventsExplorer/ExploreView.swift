//
//  ExploreView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//
import SwiftUI

struct ExploreView: View {
    // Bound reference received cleanly from MainTabBarView
    @Bindable var viewModel: ExploreViewModel
    @State private var selectedDetailEvent: Event?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.events) { event in
                            CompactExploreCardView(
                                event: event,
                                selectedEvent: $selectedDetailEvent,
                                onToggleFavorite: { event in
                                    viewModel.toggleFavourite(for: event)
                                }
                            )
                            .frame(width: 350)
                            .id(event.id)
                            .onTapGesture {
                                selectedDetailEvent = event
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .frame(height: 180)
            }

        }
    }


}
