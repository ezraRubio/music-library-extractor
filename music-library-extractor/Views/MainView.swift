//
//  MainView.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 10/08/2023.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var libraryViewModel: LibraryViewModel
    @Binding var currentMenuSelection: Int
    @State private var showEmptyLibraryAlert : Bool = false
    @State private var isExtractFromLibraryDisabled: Bool = false
    @State private var isPresentFileImporter: Bool = false
    
    var body: some View {
        VStack {
            Text("Tool for extracting your music library from Apple's Music App")
                .padding()
                .bold()


            Text("Click in the button below to start")
                .padding()
            Spacer()
            Button("Extract Library from Apple Music") {
                libraryViewModel.generateSongListFromItunes {
                    if !libraryViewModel.songs.isEmpty {
                        self.currentMenuSelection = 1
                    } else {
                        showEmptyLibraryAlert = true
                    }
                }
            }
                .padding()
                .disabled(isExtractFromLibraryDisabled)
            Button("Import CSV file") {
                self.isExtractFromLibraryDisabled = true
                self.isPresentFileImporter = true
            }
                .fileImporter(isPresented: $isExtractFromLibraryDisabled, allowedContentTypes: [.fileURL, .text]) {result in
                    switch result {
                    case .success(let file):
                        let gotAccess = file.startAccessingSecurityScopedResource()
                        if !gotAccess { return }
                        libraryViewModel.generateSongListFromCSV(file) {
                            file.stopAccessingSecurityScopedResource()
                            if !libraryViewModel.mediaItems.isEmpty {
                                self.currentMenuSelection = 1
                            } else {
                                print("error on completion")
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }

            Spacer()
        }
        .alert(isPresented: $showEmptyLibraryAlert) {
            Alert(  
                title: Text("Empty music library"),
                message: Text("An empty music library cannot be extracted"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(libraryViewModel: LibraryViewModel(), currentMenuSelection: Binding(get: {
            return 0
        }, set: { _ in
            
        }))
    }
}
