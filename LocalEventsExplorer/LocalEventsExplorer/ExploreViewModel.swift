//
//  ExploreViewModel.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import Foundation
import MapKit
import Observation
import CoreLocation
import SwiftUI

@MainActor
@Observable
final class ExploreViewModel: NSObject, CLLocationManagerDelegate {
    // Data States
    var events: [Event] = []
    var isLoading: Bool = false

    // Location States
    var currentUserLocation: CLLocation?
    private let locationManager = CLLocationManager()

    // Map & Interaction States
    var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.0447, longitude: -114.0719),
            latitudinalMeters: 1200,
            longitudinalMeters: 1200
        )
    )
    var scrolledID: Int64?
    var tappedPinID: Int64?

    // Dependencies
    private let service: EventServiceProtocol
    private let coreDataManager = CoreDataManager.shared

    /// Standard Dependency Injection Initializer
     init(service: EventServiceProtocol) {
         self.service = service
         super.init()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
     }

    /// Core method to initiate location gathering and fetch events
    func requestLocationAndLoadData() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Fallback: load events without user location metrics
            loadExploreEvents()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            loadExploreEvents()
        }
    }

    /// Fetches backend events using your service architecture
    func loadExploreEvents() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let fetchedEvents = try await service.fetchEvents()

                // Process events with distance calculations if user location is available
                self.events = processEventsWithDistance(fetchedEvents)

                if self.scrolledID == nil {
                    self.scrolledID = self.events.first?.id
                }
                self.isLoading = false
            } catch {
                print("❌ Explore map failed to fetch remote events: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    /// Iterates through fetched events to attach distance calculations
    private func processEventsWithDistance(_ remoteEvents: [Event]) -> [Event] {
        guard let userLoc = currentUserLocation else { return remoteEvents }

        return remoteEvents.map { event in
            let eventLoc = CLLocation(latitude: event.latitude, longitude: event.longitude)
            let distanceInMeters = userLoc.distance(from: eventLoc)
            let distanceInKilometers = distanceInMeters / 1000.0
            let formattedDistance = String(format: "%.1f km away", distanceInKilometers)

            var mutableEvent = event
            mutableEvent.distanceFromUser = formattedDistance
            return mutableEvent
        }
    }

    /// Responds smoothly when the user drags/swipes across the horizontal carousel items
    func processCarouselScroll(to newID: Int64?) {
        guard let newID = newID,
              let targetEvent = events.first(where: { $0.id == newID }) else { return }

        if tappedPinID != newID {
            tappedPinID = nil
        }
        updateCameraPosition(latitude: targetEvent.latitude, longitude: targetEvent.longitude)
    }

    /// Shared state wrapper method to handle heart bookmark persistence writes
    func toggleFavourite(for event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        let newStatus = !events[index].isFavourite

        events[index] = Event(
            id: event.id, title: event.title, venue: event.venue, venueImage: event.venueImage,
            eventDescription: event.eventDescription, eventImages: event.eventImages,
            date: event.date, startTime: event.startTime, endTime: event.endTime,
            latitude: event.latitude, longitude: event.longitude, isFavourite: newStatus,
            distanceFromUser: events[index].distanceFromUser
        )

        Task {
            try? await coreDataManager.updateFavouriteStatus(eventID: event.id, isFavourite: newStatus)
        }
    }

    private func updateCameraPosition(latitude: Double, longitude: Double) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            position = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                )
            )
        }
    }

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

