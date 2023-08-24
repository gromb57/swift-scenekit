//
//  ContentView.swift
//  swift-scenekit
//
//  Created by Jerome Bach on 24/08/2023.
//


import SwiftUI
import SceneKit

struct ContentView: View {
    
    @EnvironmentObject var cubeRotation: CubeRotation
    
    var body: some View {
        VStack {
            SceneView(scene: cubeRotation.scene)
        }
        .padding()
        .toolbar(content: {
            Text("Use Spline")
            Toggle("Use spline",
                   isOn: $cubeRotation.useSpline).toggleStyle(.switch)
        })
    }
}
