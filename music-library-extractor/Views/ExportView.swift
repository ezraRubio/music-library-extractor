//
//  SettingsView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 10/08/2023.
//

import SwiftUI

struct ExportView: View {
    @StateObject var viewModel = ExportViewViewModel()
    @ObservedObject var libraryViewModel: LibraryViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("Select what data you want to include on your export: ")
            HStack {
                Toggle("Title", isOn: $viewModel.includeTitle)
                    .disabled(true)
                Toggle("Artist", isOn: $viewModel.includeArtist)
                    .disabled(true)
                Toggle("Genre", isOn: $viewModel.includeGenre)
                    .disabled(true)
                Toggle("Total Time", isOn: $viewModel.includeTotalTime)
                    .disabled(true)
            }
            HStack {
                Toggle("Album", isOn: $viewModel.includeAlbum)
                    .disabled(true)
                Toggle("Track Number", isOn: $viewModel.includeTrackNumber)
                    .disabled(true)
            }
            HStack {
                Toggle("Release Date", isOn: $viewModel.includeReleaseDate)
                    .disabled(true)
                Toggle("Released Year", isOn: $viewModel.includeReleaseYear)
                    .disabled(true)
            }
            HStack {
                Toggle("Sample Rate", isOn: $viewModel.includeSampleRate)
                    .disabled(true)
                Toggle("Purchased", isOn: $viewModel.includePurchased)
                    .disabled(true)
            }
            
            Spacer()
            Button("Export as .csv") {
                viewModel.exportCSV(libraryViewModel.mediaItems)
            }
            .disabled(libraryViewModel.mediaItems.isEmpty)
            if libraryViewModel.mediaItems.isEmpty {
                Text("First you have to extract the music library.")
            }
            Spacer()
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(libraryViewModel: LibraryViewModel())
    }
}
