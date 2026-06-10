//
//  APIClient.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//
import Foundation

final class APIClient: Sendable {
    private let parser: JSONDataParser
    init(parser: JSONDataParser = JSONDataParser()) {
        self.parser = parser
    }
    /// Fetches data from a given string URL and returns the decoded model type.
    func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw EventError.invalidURL
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EventError.unknown(URLError(.badServerResponse))
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw EventError.serverError(statusCode: httpResponse.statusCode)
            }
            // Decode dynamically into the requested type
            guard let url = Bundle.main.url(forResource: "eventList", withExtension: "json") else {
                throw URLError(.fileDoesNotExist)
            }
            let data2 = try Data(contentsOf: url)
           let reult =   try JSONDecoder().decode([Event].self, from: data2)
            print(reult.count)
            return try parser.decode(T.self, from: data2)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                throw EventError.noInternetorTimeout
            default:
                throw EventError.unknown(error)
            }
        } catch let error as EventError {
            throw error
        } catch {
            throw EventError.unknown(error)
        }
    }
}
