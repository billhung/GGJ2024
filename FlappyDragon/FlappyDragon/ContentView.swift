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
    var viewModel: ViewModel //app model
    
    @State private var enlarge = false //test code to make a sphere bigger
    @State private var showImmersiveSpace = false //immersive space or stay in AR, default false
    @State private var immersiveSpaceIsShown = false //immersive space or stay in AR, default false
    private let dragonScale:Float = 0.01 //default in meters
    private let ballScale:Float = 0.1 //1.0 //size of the default sphere
    @State private var rotationAngle = 45.0 //initial rotation(angle) of the dragon when loaded
    @State private var rotationIncrement = 45.0 //rotation degree when clicked
    @State private var rotateByX:Double = 0.0 //initial rotation(x-axis) of the dragon when loaded
    @State private var rotateByY:Double = 0.0 //initial rotation(y-axis) of the dragon when loaded
    @State private var rotateByZ:Double = 0.0 //initial rotation(z-axis) of the dragon when loaded
    @State private var jump = false //the jump button to make dragon jumps
    @State private var lowHeight:Float = -0.3
    @State private var highHeight:Float = 0.0
    @State private var dragon: Entity?

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        RealityView { content in
            // Add the dragon upon app load
            //TODO should use viewModel.dragonEntity
            if let dragonEntity = try? await Entity(named: "Red_dragon"){
                viewModel.dragonEntity?.scale = [dragonScale,dragonScale,dragonScale]
                content.add(dragonEntity)
                debugPrint("Red_dragon added")
            }
            // Add the bamboo upon app load
            if let bambooEntity = try? await Entity(named: "Bamboo"){
                content.add(bambooEntity)
                debugPrint("Bamboo added")
            }
        } update: { content in
            // Move (translate) in y-axis
            let yPosition: Float = jump ? highHeight : lowHeight
            // Update the RealityKit content (the sphere) when SwiftUI state changes
            if let scene = content.entities.first {
                scene.transform.translation = [0.0, yPosition, 0.0]
                debugPrint("scene jumped")
            }
            
            // Update the dragon's position, and makes it jump (transform with translation on y-axis)
            dragon?.position.y = yPosition
        }
        // Initial rotation at load for the whole scene
        .rotation3DEffect(.radians(rotateByX), axis: (x: 1.0, y: 0.0, z: 0.0))
        .rotation3DEffect(.radians(rotateByY), axis: (x: 0.0, y: 1.0, z: 0.0))
        .rotation3DEffect(.radians(rotateByZ), axis: (x: 0.0, y: 0.0, z: 1.0))

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
        .toolbar { // UI Elements
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Toggle("BUTTON:PUSH ME", isOn: $jump)
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(viewModel: ViewModel())
}
