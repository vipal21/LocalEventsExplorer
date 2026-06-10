import SwiftUI
import MapKit
import CoreLocation

struct ExploreView: View {
    // Bound reference received cleanly from MainTabBarView
    @Bindable var viewModel: ExploreViewModel
    @State private var selectedDetailEvent: Event?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map() {}
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .ignoresSafeArea(edges: .top)

                carouselOverlaySection
            }
        }
        // Fix 2: Keep the carousel synchronized when scrolling triggers pin status mutations
        .onChange(of: viewModel.scrolledID) { _, newScrollID in
            guard let validID = newScrollID else { return }
            withAnimation(.easeInOut) {
                viewModel.tappedPinID = validID
            }
            viewModel.processCarouselScroll(to: validID)
        }
        // Fix 3: Keep the carousel synchronized if a map interaction adjusts the selection type binding
        .onChange(of: viewModel.tappedPinID) { _, newPinID in
            guard let validPinID = newPinID else { return }
            if viewModel.scrolledID != validPinID {
                withAnimation(.easeInOut) {
                    viewModel.scrolledID = validPinID
                }
            }
        }
        .onAppear {
            viewModel.requestLocationAndLoadData()
        }
    }

    private var carouselOverlaySection: some View {
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
            .scrollTargetLayout()
        }
        .frame(height: 180)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $viewModel.scrolledID)
    }
}
