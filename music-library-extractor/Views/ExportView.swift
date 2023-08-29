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
            VStack {
                Text("Select what data you want to include on your export: ")
                    .padding(.top, 30)
                
                HStack {
                    Toggle("Title", isOn: $viewModel.includeTitle)
                    Toggle("Artist", isOn: $viewModel.includeArtist)
                    Toggle("Genre", isOn: $viewModel.includeGenre)
                    Toggle("Total Time", isOn: $viewModel.includeTotalTime)
                }
                HStack {
                    Toggle("Album", isOn: $viewModel.includeAlbum)
                    Toggle("Track Number", isOn: $viewModel.includeTrackNumber)
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
            VStack {
                Text("Name for the exported file: ")
                    .padding(.top, 50)
                HStack {
                    TextField("File Name", text: $viewModel.fileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                    Text(".csv")
                }
                .padding([.leading, .trailing], 200)
                .fixedSize()

                if !viewModel.error.isEmpty {
                    Text(viewModel.error)
                        .foregroundColor(.red)
                }
                Button("Export as .csv") {
                    viewModel.exportCSV(libraryViewModel.mediaItems)
                }
                .disabled(libraryViewModel.mediaItems.isEmpty)
                if viewModel.isFileCreated {
                    Text("Export file successfuly created")
                        .foregroundColor(.green)
                }
                if libraryViewModel.mediaItems.isEmpty {
                    Text("First you have to extract the music library.")
                }
            }
            .padding()
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(libraryViewModel: LibraryViewModel())
    }
}
