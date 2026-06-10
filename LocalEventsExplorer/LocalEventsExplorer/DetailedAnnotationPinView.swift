//
//  DetailedAnnotationPinView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI
import CoreLocation

struct DetailedAnnotationPinView: View {
    let event: Event
    let isSelected: Bool
    let userLocation: CLLocation
    private var distanceString: String {
        let eventLoc = CLLocation(latitude: event.latitude, longitude: event.longitude)
        let distanceInMeters = userLocation.distance(from: eventLoc)
        return String(format: "%.1f km away", distanceInMeters / 1000.0)
    }
    var body: some View {
        VStack(spacing: 4) {
            if isSelected {
                HStack(spacing: 10) {
                    // UPDATED: Replaced basic native AsyncImage logic block with your performance CachedAsyncImage component
                    CachedAsyncImage(urlString: event.venueImage)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        // Safe layout clipping overlay logic configuration protection helper
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                    // 2. Information Text Elements Stack
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                            Text(event.venue)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.blue)
                            Text(distanceString)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 130, alignment: .leading)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
            // Map Marker Anchor
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(isSelected ? .blue : .red)
                .shadow(radius: 3)
        }
    }
}
