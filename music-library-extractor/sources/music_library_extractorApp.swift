//
//  music_library_extractorApp.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 14/03/2023.
//

import SwiftUI

@main
struct music_library_extractorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Music Library Extractor") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: """
                                App created by Ezra Rubio
                                For inquiries, feedback, hiring: \
                                https://www.ezrarubio.com/contact
                                """,
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.boldSystemFont(
                                        ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(
                                rawValue: "Copyright"
                            ): "© 2023 Ezra Rubio"
                        ]
                    )
                }
            }
        }
    }
}
