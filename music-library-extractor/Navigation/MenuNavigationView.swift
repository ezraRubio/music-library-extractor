//
//  NavigationView.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 13/08/2023.
//

import SwiftUI

struct MenuNavigationView: View {
    @State var currentMenuSelection = 0
    @StateObject var libraryViewModel: LibraryViewModel = LibraryViewModel()
    
    var body: some View {
        NavigationSplitView {
            MenuView(currentMenuSelection: $currentMenuSelection)
        } detail: {
            switch currentMenuSelection {
                case 1:
                    ResultsView(libraryViewModel: libraryViewModel)
                case 2:
                    ExportView(libraryViewModel: libraryViewModel)
                default:
                    MainView(libraryViewModel: libraryViewModel, currentMenuSelection: $currentMenuSelection)
            }
        }
        .navigationTitle("Music Library Extractor")
        .frame(minWidth: 300, minHeight: 200)
    }
}

struct MenuNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MenuNavigationView()
    }
}
