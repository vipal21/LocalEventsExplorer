//
//  LocalEventsExplorerTests.swift
//  LocalEventsExplorerTests
//
//  Created by vipal on 2026-06-10.
//

import XCTest
import MapKit
import CoreLocation
@testable import LocalEventsExplorer // Replace with your real app target module name


/// Explicit mock layer to prevent real network calls during testing passes
final class MockEventService: EventServiceProtocol {
    var mockEvents: [Event] = []
    var shouldThrowError: Bool = false

    func fetchEvents() async throws -> [Event] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 404, userInfo: nil)
        }
        return mockEvents
    }
}


@MainActor
final class ExploreViewModelTests: XCTestCase {
    private var sut: ExploreViewModel!
    private var mockService: MockEventService!

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        sut = ExploreViewModel(service: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - API Caching & Retrieval Test Passes

    func testLoadExploreEventsSuccessPopulatesCollection() async {
        // Arrange
        let expectedEvent = Event(
            id: 101, title: "Stampede Show", venue: "Saddledome", venueImage: "",
            eventDescription: "", eventImages: [], date: "2026-07-01T00:00:00",
            startTime: "18:00", endTime: "22:00", latitude: 51.0374, longitude: -114.0521,
            isFavourite: false, distanceFromUser: nil
        )
        mockService.mockEvents = [expectedEvent]

        // Act
        sut.loadExploreEvents()

        // Allow the async Swift concurrency Task context matrix to complete execution passes
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.events.count, 1)
        XCTAssertEqual(sut.events.first?.id, 101)
        XCTAssertEqual(sut.scrolledID, 101)
    }

    func testLoadExploreEventsFailureMaintainsEmptyCollection() async {
        // Arrange
        mockService.shouldThrowError = true

        // Act
        sut.loadExploreEvents()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.events.isEmpty)
    }

    // MARK: - CoreLocation Distance Metric Tracking Tests

    func testLocationParsingAttachesDynamicUserDistanceMetrics() async {
        // Arrange
        sut.currentUserLocation = CLLocation(latitude: 51.0474, longitude: -114.0597)
        let nearEvent = Event(
            id: 202, title: "Downtown Fest", venue: "Olympic Plaza", venueImage: "",
            eventDescription: "", eventImages: [], date: "2026-07-15T00:00:00",
            startTime: "12:00", endTime: "16:00", latitude: 51.0458, longitude: -114.0578,
            isFavourite: false, distanceFromUser: nil
        )
        mockService.mockEvents = [nearEvent]

        // Act
        sut.loadExploreEvents()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertNotNil(sut.events.first?.distanceFromUser)
    }

    // MARK: - Carousel Interaction & Selection State Matrices

    func testSelectPinDirectlyUpdatesTrackingIdentifiers() {
        // Arrange
        let testEvent = Event(
            id: 303, title: "Art Gala", venue: "Gallery", venueImage: "",
            eventDescription: "", eventImages: [], date: "2026-08-01T00:00:00",
            startTime: "19:00", endTime: "23:00", latitude: 51.0447, longitude: -114.0719,
            isFavourite: false, distanceFromUser: nil
        )
        sut.events = [testEvent]

        // Act
        sut.selectPinDirectly(for: 303)

        // Assert
        XCTAssertEqual(sut.tappedPinID, 303)
        XCTAssertEqual(sut.scrolledID, 303)
    }

    func testProcessCarouselScrollResetsDivergentTappedPinState() {
        // Arrange
        let initialEvent = Event(
            id: 404, title: "Event A", venue: "V", venueImage: "", eventDescription: "",
            eventImages: [], date: "2026-06-10", startTime: "10", endTime: "12",
            latitude: 51.0, longitude: -114.0, isFavourite: false, distanceFromUser: nil
        )
        sut.events = [initialEvent]
        sut.tappedPinID = 999 // Different ID represents a previously selected marker pin

        // Act
        sut.processCarouselScroll(to: 404)

        // Assert
        XCTAssertNil(sut.tappedPinID)
    }

    // MARK: - Persistence Array Mutations

    func testToggleFavouriteInvertsStateInline() {
        // Arrange
        let targetEvent = Event(
            id: 505, title: "Concert", venue: "Theater", venueImage: "",
            eventDescription: "", eventImages: [], date: "2026-09-20T00:00:00",
            startTime: "20:00", endTime: "23:00", latitude: 51.04, longitude: -114.07,
            isFavourite: false, distanceFromUser: nil
        )
        sut.events = [targetEvent]

        // Act
        sut.toggleFavourite(for: targetEvent)

        // Assert
        XCTAssertTrue(sut.events[0].isFavourite)
    }
}

