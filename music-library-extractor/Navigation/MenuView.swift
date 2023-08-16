//
//  MenuView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 13/08/2023.
//

import SwiftUI

struct MenuView: View {
    let menuItems: [MenuItem] = [
        .init(menuName:"Home", menuImage:"house"),
        .init(menuName:"Results", menuImage:"list.dash"),
        .init(menuName:"Settings", menuImage:"gear"),
    ]
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

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(currentMenuSelection: Binding(get: {
            return 0
        }, set: { _ in
            
        }))
    }
}