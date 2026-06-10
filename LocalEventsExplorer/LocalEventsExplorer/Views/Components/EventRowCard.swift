//
//  EventRowCard.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//
import SwiftUI
import MapKit

struct EventRowCard: View {
    let event: Event
    var onSaveToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            CachedAsyncImage(urlString: event.venueImage)
                .frame(width: 85, height: 85)
                .cornerRadius(10)
                .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                    .lineLimit(2)

                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text(event.date)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text(event.venue)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Optional Layout Bonus: Show the dynamic user distance calculation string right inside the row card
                if let distance = event.distanceFromUser {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(distance)
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .bold()
                            .lineLimit(1)
                    }
                } else {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("\(event.startTime) - \(event.endTime)")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Button(action: onSaveToggle) {
                    Image(systemName: event.isFavourite ? "heart.fill" : "heart")
                        .font(.footnote)
                        .foregroundColor(event.isFavourite ? .blue : .primary)
                        .frame(width: 30, height: 30)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

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
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func openMapsForDirections() {
        let location = CLLocation(latitude: event.latitude, longitude: event.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = event.title
        mapItem.openInMaps()
    }
}
