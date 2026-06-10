//
//  CompactExploreCardView.swift
//  LocalEventsExplorer
//
//  Created by vipal on 2026-06-10.
//

import SwiftUI

struct CompactExploreCardView: View {
    let event: Event
    @Binding var selectedEvent: Event?
    let onToggleFavorite: (Event) -> Void

    private let thumbnailSize: CGFloat = 85
    private let actionButtonSize: CGFloat = 30
    private let cornerRadius: CGFloat = 10
    private let cardCornerRadius: CGFloat = 14

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            CachedAsyncImage(urlString: event.eventImages.first ?? "")
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            metadataTextSection

            Spacer()

            actionButtonsSection
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                .onTapGesture {
                    selectedEvent = event
                }
        )
    }

    // MARK: - Extracted Component Views for Line & Function Length Compliance

    private var metadataTextSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(event.title)
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
                .lineLimit(2)

            // Injected: Beautifully formatted calendar date row
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text(event.formattedDateDisplay)
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
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    onToggleFavorite(event)
                }
            }) {
                Image(systemName: event.isFavourite ? "heart.fill" : "heart")
                    .font(.footnote)
                    .foregroundColor(event.isFavourite ? .blue : .primary)
                    .frame(width: actionButtonSize, height: actionButtonSize)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.onCardButton)

            Button(action: openAppleMapsDirections) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .frame(width: actionButtonSize, height: actionButtonSize)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.onCardButton)
        }
    }

    private func openAppleMapsDirections() {

      }
}


// MARK: - Safe Button Style Helper to prevent click leakage
fileprivate struct OnCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

fileprivate extension ButtonStyle where Self == OnCardButtonStyle {
    static var onCardButton: OnCardButtonStyle { OnCardButtonStyle() }
}
