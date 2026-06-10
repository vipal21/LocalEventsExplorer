# LocalEventsExplorer
# 📍 LocalEventsExplorer - SwiftUI CoreLocation & MapKit Matrix App

LocalEventsExplorer is a high-performance, modern iOS application built using **SwiftUI** and modern Swift Concurrency. It orchestrates real-time event exploration via map canvases and clean list views through a rigid **Single Source of Truth** dependency injection pipeline.

---

## 🚀 Key Functional Architecture Features

*   **Unified Reactive States**: Driven entirely by the modern `@Observable` macro and isolated safely on the `@MainActor`. All tabs share a single coordinate data structure instance.
*   **Dual-Axis Interaction Tracking**: Smooth bidirectional sync layer where sliding across the horizontal bottom card carousel natively expands map annotations, and scrolling through content highlights map pin layers.
*   **Intelligent Syncing Data Protocol**: Custom offline caching engine that cross-examines incoming network API streams against internal Core Data stores to prevent redundant UI layout updates or flickering.
*   **Dynamic Distance Calculations**: Leverages full system `CoreLocation` tracking metrics to measure and append real-time relative user distances to loaded models.
*   **Zero-Warning Layout Layers**: Leverages modern warning-free `MKMapItem` and `MKAddress` targets explicitly optimized for iOS 26.0+.

---

## 🛠️ Tech Stack & Requirements

*   **iOS Development Baseline**: iOS 17.0+ / Swift 6.0 Architecture
*   **UI Framework**: SwiftUI layout matrices paired with modern `NavigationStack` structures
*   **Map Engineering**: MapKit Native Selection API integrations
*   **Persistence Management**: Core Data asynchronous background contexts
*   **Validation Rules Enforced**: Strict `.swiftlint.yml` guidelines (No force unwraps, explicit identifier length rules, and strict line-length limitations).

---

## ⚙️ Initial Project Configuration Setup

To ensure system `CoreLocation` updates behave accurately across simulator and target devices, look inside your target app build parameters and verify that the following system property key string tokens are registered directly inside your **`Info.plist`** file matrix:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>LocalEventsExplorer requires your live geographic location metrics to calculate real-time distance measurements to local event venues.</string>
```

---

## 🧪 Comprehensive Automated Testing Suite

The project includes an isolated automated test framework using `XCTest` alongside lightweight mock layers (`MockEventService`) to safely evaluate state variations without making physical network transactions.

Run the test suite seamlessly inside Xcode by applying the standard shortcut pattern:
👉 `Cmd + U`


## Architecture and Sequence Diagrams
<img width="1408" height="768" alt="image_9946d347" src="https://github.com/user-attachments/assets/645a0e2e-0f6b-4207-a7ba-2aed30a51f76" />


<img width="1408" height="768" alt="image_9bc8141e" src="https://github.com/user-attachments/assets/4a0ec3ab-939e-4e6f-a8b2-cada310ff3d6" />



