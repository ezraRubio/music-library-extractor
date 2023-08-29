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
                        self.currentMenuSelection = 1
                    }
                }
            }
            Spacer()
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
