//
//  ToSpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 18/03/2024.
//

import SwiftUI

struct ToSpotifyView: View {
    let toSpotifyItems: [SpotifyLibItem]
    
    var body: some View {
        Table(toSpotifyItems) {
            TableColumn("Title", value: \.title)
            TableColumn("Artist", value: \.artist)
            TableColumn("Album", value: \.album)
            TableColumn("Not Found on Spotify", value: \.formattedNotFoundOnSpotify)
            TableColumn("Already in your Spotify Library", value: \.formattedOnUserLibrary)
        }
    }
}

#Preview {
    ToSpotifyView(toSpotifyItems: [])
}
