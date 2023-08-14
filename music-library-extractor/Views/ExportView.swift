//
//  SettingsView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 10/08/2023.
//

import SwiftUI

struct ExportView: View {
    @StateObject var viewModel = ExportViewViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Toggle("Title", isOn: $viewModel.includeTitle)
                Toggle("Artist", isOn: $viewModel.includeArtist)
                Toggle("Genre", isOn: $viewModel.includeGenre)
                Toggle("Total Time", isOn: $viewModel.includeTotalTime)
            }
            HStack {
                Toggle("Album", isOn: $viewModel.includeAlbum)
                Toggle("Track Number", isOn: $viewModel.includeTrackNumber)
                Toggle("Artwork", isOn: $viewModel.includeArtwork)
            }
            HStack {
                Toggle("Release Date", isOn: $viewModel.includeReleaseDate)
                Toggle("Released Year", isOn: $viewModel.includeReleaseYear)
            }
            HStack {
                Toggle("Sample Rate", isOn: $viewModel.includeSampleRate)
                Toggle("Purchased", isOn: $viewModel.includePurchased)
            }
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}
