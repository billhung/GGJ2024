//
//  FlappyDragonApp.swift
//  FlappyDragon
//
//  Created by HC on 2024/01/27.
//

import SwiftUI

@main
struct FlappyDragonApp: App {
    // The app's data model.
    @State private var viewModel = ViewModel()
    // Default code loading the app's view
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
