//
//  ToSpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 18/03/2024.
//

import SwiftUI

struct ToSpotifyView: View {
    let toSpotifyItems: [SpotifyLibItem]
    @State private var selectedItems: [Bool] = []
    
    var body: some View {
        Table(toSpotifyItems) {
            TableColumn("Title", value: \.title)
            TableColumn("Artist", value: \.artist)
            TableColumn("Album", value: \.album)
            TableColumn("Not Found on Spotify", value: \.formattedNotFoundOnSpotify)
            TableColumn("Already in your Spotify Library", value: \.formattedOnUserLibrary)
            TableColumn("Add to Spotify Library") { item in
                if let index = self.toSpotifyItems.firstIndex(of: item) {
                    Toggle("", isOn: Binding<Bool>(
                        get: {
                            guard index < self.selectedItems.count else { return false }
                            return self.selectedItems[index]
                        },
                        set: { newValue in
                            self.updateSelection(for: item, with: newValue)
                        }
                    ))
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                } else {
                    // Handle case where item is not found
                    EmptyView()
                }
            }
        }
    }
    
    private func updateSelection(for item: SpotifyLibItem, with newValue: Bool) {
        if let index = self.toSpotifyItems.firstIndex(of: item) {
            if index < self.selectedItems.count {
                self.selectedItems[index] = newValue
            } else {
                // If the selected array doesn't have enough elements,
                // expand it and then set the new value
                self.selectedItems.append(contentsOf: Array(repeating: false, count: index - self.selectedItems.count + 1))
                self.selectedItems[index] = newValue
            }
        }
    }
}

#Preview {
    ToSpotifyView(toSpotifyItems: [])
}
