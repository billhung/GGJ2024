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
    private let dragonScale:Float = 0.01 //default in meters
    private let ballScale:Float = 0.1 //1.0 //size of the default sphere
    @State private var rotationAngle = 45.0
    @State private var rotationIncrement = 45.0
    @State private var rotateByX:Double = 0.0
    @State private var rotateByY:Double = 0.0
    @State private var rotateByZ:Double = 0.0
    @State private var jump = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                //TODO make this ball disappear
                scene.scale = [ballScale,ballScale,ballScale]
                content.add(scene)
            }
            // Add the dragon upon app load
            if let dragon = try? await Entity(named: "Red_dragon"){
                dragon.scale = [dragonScale,dragonScale,dragonScale]
                content.add(dragon)
                debugPrint("GGJ2024_Dragon_Rigged_Yellow added")
            }
        } update: { content in
            // move (translate) in y-axis
            let yPosition: Float = jump ? 0.3 : 0.0
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 1.4 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
                debugPrint("scene enlarged toggle")
                scene.transform.translation = [0.0, yPosition, 0.0]
                debugPrint("scene jumped")
            }
            
            // TODO Get the dragon and makes it jump (transform with translation on y-axis)
//            let dragon = content.entities.index(<#T##i: Int##Int#>, offsetBy: <#T##Int#>)
//                //            content.entities.first?.transform.translation = [0.0, yPosition, 0.0]
//                dragon.transform.translation = [0.0, yPosition, 0.0]
            
        }
        .rotation3DEffect(.radians(rotateByX), axis:.x) //rotate up on load
        .rotation3DEffect(.radians(rotateByY), axis:.y) //rotate sideway on load
        .rotation3DEffect(.radians(rotateByZ), axis:.z) //rotate up on load

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
        // GESTURE 1, TAP TO ROTATE BY 45 DEGREES
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
            //rotate by 45 degrees + increment when tapped
            rotationAngle = rotationAngle + rotationIncrement
            rotateByY = Double(rotationAngle)
        })
        // GESTURE 2, DRAG TO ROTATE SMOOTHLY
        .gesture(DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                let location3d = value.convert(value.location3D, from:.local, to:.scene)
                let startLocation = value.convert(value.startLocation3D, from:.local, to:.scene)
                let delta = location3d - startLocation
                rotateByY = Double(atan(delta.x * 100))
            })
        .toolbar { // UI Elements
            ToolbarItemGroup(placement: .bottomOrnament) { //TODO .bottomBar works but too small, .topBarTrailing didn't show
                VStack (spacing: 12) {
                    //Toggle("Enlarge RealityView Content", isOn: $enlarge)
                    Toggle("MAKE ME(メ) LAUGH わらわせて", isOn: $jump)
                    //Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
