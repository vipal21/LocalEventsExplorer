//
//  EventDetailView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    var onSaveToggle: () -> Void
    // Tracks the favourite state locally on this screen so the UI updates instantly
    @State private var isCurrentlyFavourite: Bool
    // Custom initializer to set up the initial local state from the passed Event model
    init(event: Event, onSaveToggle: @escaping () -> Void) {
        self.event = event
        self.onSaveToggle = onSaveToggle
        self._isCurrentlyFavourite = State(initialValue: event.isFavourite)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Carousel Layer using CachedAsyncImage
                imageHeaderLayer
                VStack(alignment: .leading, spacing: 12) {
                    // Event Title
                    Text(event.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    Divider()
                    // Date Row
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text(event.formattedDateDisplay)
                                .font(.body)
                            Text("Event Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    // Venue Location Row
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text(event.venue)
                                .font(.body)
                            Text("Location Venue")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    // Time Frame Row with Bookmark Action
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "clock")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("\(event.startTime) - \(event.endTime)")
                                .font(.body)
                            Text("Schedule Constraints")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        // Circle Action Buttons
                        HStack(spacing: 8) {
                            // Favourite / Save Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    isCurrentlyFavourite.toggle() // Flips icon instantly
                                    onSaveToggle() // Triggers view model database sync
                                }
                            }) {
                                Image(systemName: isCurrentlyFavourite ? "bookmark.fill" : "bookmark")
                                    .font(.footnote)
                                    .foregroundColor(isCurrentlyFavourite ? .blue : .primary)
                                    .frame(width: 30, height: 30)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            // Apple Maps Directions Button
                            Button(action: openMapsForDirections) {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                    // Event Description Area
                    Text("About This Event")
                        .font(.headline)
                    Text(event.eventDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Event Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    // Dynamic Carousel Header using your custom CachedAsyncImage
    @ViewBuilder
    private var imageHeaderLayer: some View {
        if event.eventImages.isEmpty || (event.eventImages.count == 1 && event.eventImages.first?.isEmpty == true) {
            placeholderView(label: "No Image Available")
                .frame(height: 250)
        } else if event.eventImages.count == 1, let firstImage = event.eventImages.first {
            CachedAsyncImage(urlString: firstImage)
                .frame(height: 250)
                .clipped()
        } else {
            TabView {
                ForEach(event.eventImages, id: \.self) { imageUrl in
                    CachedAsyncImage(urlString: imageUrl)
                        .frame(height: 250)
                        .clipped()
                }
            }
            .frame(height: 250)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    // Fallback UI Asset
    private func placeholderView(label: String) -> some View {
        ZStack {
            Color.teal.opacity(0.15)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    // Launches Apple Maps to calculate a driving route
    private func openMapsForDirections() {
        let coordinates = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        let targetLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let mapItem = MKMapItem(location: targetLocation, address: nil)
        mapItem.name = event.title
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
