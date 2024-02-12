//
//  SpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 03/01/2024.
//

import SwiftUI

struct SpotifyView: View {
    @ObservedObject var viewModel = SpotiftyViewModel()
    
    var body: some View {
        Link("Authorize with Spotify", destination: viewModel.logInSpotify())
        .buttonStyle(.bordered)
        .padding()
        .onOpenURL(perform: { url in
            viewModel.refreshToken(url)
        })
    }
}

#Preview {
    SpotifyView()
}
