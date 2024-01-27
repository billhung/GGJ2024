//
//  ContentView.swift
//  FlappyDragon
//
//  Created by HC on 2024/01/27.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    private let dragonScale:Float = 0.001
    @State private var rotationAngle = 45

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
            // Add the dragon upon app load
            if let dragon = try? await Entity(named: "Low_Poly_Dragon"){
                dragon.scale = [dragonScale,dragonScale,dragonScale]
//                dragon.scale = [repeating:dragonScale]
//                dragon.rotate = [rotationAngle,rotationAngle,rotationAngle] //ERROR
                // rotate the dragon by ___ degree
                //dragon.transform.rotate(self: CGContext, by: 45.0)//rotateAngle(Angle:45) //error
                content.add(dragon)
                debugPrint("Low_Poly_Dragon added")
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 1.4 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
                debugPrint("scene enlarged")
            }
            // if the dragon is clicked
//            if let dragon = content.entities.first {
//                let uniformScale: Float = enlarge ? 2.0 : 1.0
//                dragon.transform.scale = [uniformScale, uniformScale, uniformScale]
//                debugPrint("dragon enlarged")
//            }
        }
        .rotation3DEffect(.degrees(45.0), axis:(x:0,y:1,z:0))
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Toggle("Enlarge RealityView Content", isOn: $enlarge)
                    Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
