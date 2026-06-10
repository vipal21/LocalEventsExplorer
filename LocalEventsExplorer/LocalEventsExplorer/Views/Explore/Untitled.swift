//
//  Untitled.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import CoreLocation
import SwiftUI
import MapKit

extension ExploreViewModel:CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate Methods

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .restricted, .denied, .notDetermined:
                loadExploreEvents()
            @unknown default:
                loadExploreEvents()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.currentUserLocation = location
            // Re-center map over the user dynamically
            self.position = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1500,
                    longitudinalMeters: 1500
                )
            )
            // Trigger network download now that location is configured
            loadExploreEvents()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("⚠️ Location fetch failed: \(error.localizedDescription)")
            // Recover by loading default events cleanly
            loadExploreEvents()
        }
    }
}
