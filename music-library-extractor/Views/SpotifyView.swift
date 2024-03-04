//
//  SpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 03/01/2024.
//

import SwiftUI

struct SpotifyView: View {
    @StateObject var viewModel = SpotiftyViewModel()
    @StateObject var libraryViewModel = LibraryViewModel()
    
    var body: some View {
        if viewModel.isAuthorized {
            VStack {
                HStack {
                    Text("Welcome \(viewModel.currentUser?.displayName ?? "")")
                    AsyncImage(url: viewModel.currentUser?.images?.first?.url)
                }
                .padding()
                Spacer()
                
                if !libraryViewModel.songs.isEmpty {
                    Text("Search Spotify for your music now")
                } else {
                    Text("You need to extract your music library first from the main tab")
                }
                Spacer()
            }
        } else {
            Link("Authorize with Spotify", destination: viewModel.logInSpotify())
            .buttonStyle(.bordered)
            .padding()
            .onOpenURL(perform: { url in
                viewModel.refreshToken(url)
            })
        }
    }
}

#Preview {
    SpotifyView()
}
