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
    
    var body: some View {
        VStack {
            Text("Tool for extracting your music library from Apple's Music App")
                .padding()
                .bold()

            if !libraryViewModel.songs.isEmpty {
                Spacer()
                Text("check the results tab")
            } else {
                Text("Click in the button below to start")
                    .padding()
                Spacer()
                Button("Extract Library") {
                    libraryViewModel.generateSongList {
                        if !libraryViewModel.songs.isEmpty {
                            self.currentMenuSelection = 1
                        } else {
                            showEmptyLibraryAlert = true
                        }
                    }
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
