//
//  FlappyDragonApp.swift
//  FlappyDragon
//
//  Created by HC on 2024/01/27.
//

import SwiftUI

@main
struct FlappyDragonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
