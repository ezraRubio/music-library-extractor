//
//  SpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 03/01/2024.
//

import SwiftUI

struct SpotifyView: View {
    @StateObject var viewModel = SpotiftyViewModel()
    @ObservedObject var libraryViewModel = LibraryViewModel()
    
    var body: some View {
        if viewModel.isAuthorized {
            VStack {
                HStack {
                    Text("Welcome \(viewModel.currentUser?.displayName ?? "")")
                    AsyncImage(url: viewModel.currentUser?.images?.first?.url)
                }
                .padding()
                Spacer()
                
                if !viewModel.itemsToUserSpotify.isEmpty {
                    ToSpotifyView(toSpotifyItems: viewModel.itemsToUserSpotify)
                }
                
                if !libraryViewModel.mediaItems.isEmpty {
                    Button("Search Spotify for your music now") {
                        Task {
                            await viewModel.processExtractedLibraryItems(mediaItems: libraryViewModel.mediaItems)
                        }
                    }
                } else {
                    Text("You need to extract your music library first from the home tab")
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
