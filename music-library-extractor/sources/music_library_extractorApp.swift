//
//  music_library_extractorApp.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 14/03/2023.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        print("Received URLs: \(urls)")
        // Process the URLs as needed
        // Activate the existing instance
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application did finish launching")
    }
}

@main
struct music_library_extractorApp: App {
    @ObservedObject var viewModel = SpotiftyViewModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    print("content view, received url: \(url)")
                    viewModel.refreshToken(url)
                })
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
