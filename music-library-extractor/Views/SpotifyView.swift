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
                    ToSpotifyView(spotifyViewModel: viewModel)
                }
                
                if !libraryViewModel.mediaItems.isEmpty && viewModel.itemsToUserSpotify.isEmpty {
                    Button("Search Spotify for your music now") {
                        Task {
                            await viewModel.processExtractedLibraryItems(mediaItems: libraryViewModel.mediaItems)
                        }
                    }
                    .disabled(!viewModel.isDoneProcessingItems)
                } else if !libraryViewModel.mediaItems.isEmpty && !viewModel.itemsToUserSpotify.isEmpty {
                    Button("Add selection to your Spotify Library") {
                        viewModel.processSelectedItemsIntoSpotifyLibrary()
                    }
                    .disabled(!viewModel.isDoneProcessingItems)
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
