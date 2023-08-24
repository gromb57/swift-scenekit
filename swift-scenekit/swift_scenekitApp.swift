//
//  swift_scenekitApp.swift
//  swift-scenekit
//
//  Created by Jerome Bach on 24/08/2023.
//

import SwiftUI

@main
struct swift_scenekitApp: App {
    @StateObject private var cubeRotation = CubeRotation()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cubeRotation)
        }
    }
}
