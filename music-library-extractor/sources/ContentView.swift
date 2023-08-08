//
//  ContentView.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 14/03/2023.
//
import iTunesLibrary
import SwiftUI

struct ContentView: View {
    @State var currentMenuSelection = 0
    @ObservedObject var playlistModel = MyPlaylistViewModel()
    
    let menuItems: [MenuItem] = [
        .init(menuName:"Home", menuImage:"house"),
        .init(menuName:"Results", menuImage:"list.dash"),
        .init(menuName:"Settings", menuImage:"gear"),
    ]
    
    var body: some View {
        NavigationSplitView{
            MenuView(
                menuItems: menuItems,
                currentMenuSelection: $currentMenuSelection
            )
        } detail: {
            switch currentMenuSelection {
                case 1:
                    ResultsView(playlistModel: playlistModel)
                case 2:
                    Text("Not yet implemented - coming soon")
                default:
                    MainView(playlistModel: playlistModel, currentMenuSelection: $currentMenuSelection)
            }
        }
        .navigationTitle("Music Library Extractor")
        .frame(minWidth: 300, minHeight: 200)
    }
}

struct MenuItem: Hashable {
    let menuName: String
    let menuImage: String
}

struct MenuView: View {
    let menuItems: [MenuItem]
    @Binding var currentMenuSelection: Int
    
    var body: some View {
        VStack (alignment: .leading) {
            let current = menuItems[currentMenuSelection]
            ForEach(menuItems.indices, id: \.self) {index in
                let item = menuItems[index]
                Label(item.menuName, systemImage: item.menuImage)
                    .foregroundColor(current == item ? Color(.green) : Color(.labelColor))
                    .padding()
                    .onTapGesture {
                        self.currentMenuSelection = index
                    }
            }
            Spacer()
        }
    }
}

struct MainView: View {
    let playlistModel: MyPlaylistViewModel
    @Binding var currentMenuSelection: Int
    
    var body: some View {
        VStack {
            Text("Tool for extracting your music library from Apple's Music App")
                .padding()
                .bold()

            if !playlistModel.songs.isEmpty {
                Spacer()
                Text("check the results tab")
            } else {
                Text("Click in the button below to start")
                    .padding()
                Spacer()
                Button("Extract Library") {
                    playlistModel.generateSongList {
                        self.currentMenuSelection = 1
                    }
                }
            }
            Spacer()
        }
    }
}

struct ResultsView: View {
    let playlistModel: MyPlaylistViewModel

    var body: some View {
        if !playlistModel.songs.isEmpty {
            List(playlistModel.songs, id: \.self) {
                song in Text(song)
            }
        } else {
            Text("No library extracted yet.")
        }
    }
}

class MyPlaylistViewModel: ObservableObject {
    @Published var songs : [String] = []
    
    func generateSongList(completion: @escaping () -> Void){
        do {
            let library = try ITLibrary(apiVersion: "1.0")
            var songArray = [String]()

            for item: ITLibMediaItem in library.allMediaItems {
                let song = "\(item.title) from \(item.album.title ?? "unknown") by \(item.artist?.name ?? "unknown")"
                songArray.append(song)
            }

            DispatchQueue.main.async {
                self.songs = songArray
                completion()
            }

        } catch {
            print ("Error Initializing iTunes Library: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
