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
    
    let menuItems: [MenuItem] = [
        .init(menuName:"Home", menuImage:"house"),
        .init(menuName:"Results", menuImage:"list.dash"),
        .init(menuName:"Settings", menuImage:"gear"),
    ]
    
    var body: some View {
        NavigationView {
            MenuView(
                menuItems: menuItems,
                currentMenuSelection: $currentMenuSelection
            )
            switch currentMenuSelection {
            case 1:
                Text("Not yet implemented - coming soon")
            case 2:
                Text("Not yet implemented - coming soon")
            default:
                MainView()
            }
        }
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
        VStack {
            let current = menuItems[currentMenuSelection]
            ForEach(menuItems.indices, id: \.self) {index in
                let item = menuItems[index]
                HStack {
                    Image(systemName: item.menuImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    
                    /*@START_MENU_TOKEN@*/Text(item.menuName)/*@END_MENU_TOKEN@*/
                        .foregroundColor(current == item ?
                                         Color(.green) : Color(.labelColor)
                        )
                    Spacer()
                }
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
    @ObservedObject var playlistModel = MyPlaylistViewModel()
    
    var body: some View {
        VStack {
            Text("My music library")
            Button("Extract library") {
                playlistModel.generateSongList()
            }
            
            if !playlistModel.songs.isEmpty {
                List(playlistModel.songs, id: \.self) {
                    song in Text(song)
                }
            }
        }
    }
}

class MyPlaylistViewModel: ObservableObject {
    @Published var songs : [String] = []
    
    func generateSongList(){
        do {
            let library = try ITLibrary(apiVersion: "1.0")
            var songArray = [String]()
            for item in library.allMediaItems {
                let song = "\(item.title) by \(String(describing: item.artist))"
                songArray.append(song)
            }
            DispatchQueue.main.async {
                self.songs = songArray
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
