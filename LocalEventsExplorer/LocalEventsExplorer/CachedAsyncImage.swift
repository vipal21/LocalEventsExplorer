//
//  aa.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI

// MARK: - Reusable Cached Image Component with Simple Logs
struct CachedAsyncImage: View {
    let urlString: String
    private static let sharedSession: URLSession = {
        let cache = URLCache(memoryCapacity: 50 * 1024 * 1024,
                             diskCapacity: 200 * 1024 * 1024,
                             diskPath: "APITestLabURLCache")
        URLCache.shared = cache
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = cache
        return URLSession(configuration: config)
    }()
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    private func diskCacheURL(for key: String) -> URL? {
        guard let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let safe =
            key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "image"
        return base
            .appendingPathComponent("APITestLabImageCache")
            .appendingPathComponent(safe)
    }

    private func loadImageFromDisk(for key: String) -> UIImage? {
        guard let fileURL = diskCacheURL(for: key) else { return nil }
        if let data = try? Data(contentsOf: fileURL) { return UIImage(data: data) }
        return nil
    }

    private func saveImageToDisk(_ image: UIImage, for key: String) {
        guard let fileURL = diskCacheURL(for: key) else { return }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if let data = image.pngData() { try data.write(to: fileURL, options: .atomic) }
        } catch {
            print(
                "🔴 [Disk Cache Error] \(error.localizedDescription)"
            )
        }
    }
    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .task(id: urlString) {
            // 1. Check memory cache instance
            if let cached = CacheManager.instance.get(name: urlString) {
                print("🟢 [Cache Hit] Found image in RAM for key: \(urlString)")
                self.uiImage = cached
                return
            }
            // 1.5 Check disk cache
            if let diskImage = loadImageFromDisk(for: urlString) {
                print(
                    "🟡 [Disk Cache Hit] Loaded image from disk for key: \(urlString)"
                )
                CacheManager.instance.add(image: diskImage, name: urlString)
                self.uiImage = diskImage
                return
            }
            // 2. Download bytes asynchronously from network
            print(
                "🌐 [Cache Miss] Downloading from network: \(urlString)"
            )
            guard let url = URL(string: urlString) else { return }
            isLoading = true
            do {
                let (data, _) = try await CachedAsyncImage.sharedSession.data(from: url)
                if let downloadedImage = UIImage(data: data) {
                    // 3. Populate memory cache container
                    CacheManager.instance.add(image: downloadedImage, name: urlString)
                    saveImageToDisk(downloadedImage, for: urlString)
                    print(
                        "💾 [Cache Save] Successfully saved downloaded image for key: \(urlString)"
                    )
                    self.uiImage = downloadedImage
                }
            } catch {
                print(
                    "🔴 [Cache Error] Failed downloading image: \(error.localizedDescription)"
                )
            }
            isLoading = false
        }
    }
}
