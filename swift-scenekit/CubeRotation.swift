//
//  CubeRotation.swift
//  swift-scenekit
//
//  Created by Jerome Bach on 24/08/2023.
//

import Foundation
import CoreVideo
import simd
import ModelIO
import SceneKit

class CubeRotation: ObservableObject {
    
    @Published var scene: SCNScene!
    
    @Published var useSpline = true {
        didSet {
            displayLink.invalidate()
            
            vertexRotationIndex = 1
            vertexRotationTime = 0
            cubeVertices = cubeVertexOrigins
            scene = setupSceneKit()
            
            displayLink.add(to: RunLoop.current, forMode: .default)
        }
    }

    let vertexRotations: [simd_quatd] = [
        simd_quatd(angle: 0,
                   axis: simd_normalize(simd_double3(x: 0, y: 0, z: 1))),
        simd_quatd(angle: 0,
                   axis: simd_normalize(simd_double3(x: 0, y: 0, z: 1))),
        simd_quatd(angle: .pi * 0.05,
                   axis: simd_normalize(simd_double3(x: 0, y: 1, z: 0))),
        simd_quatd(angle: .pi * 0.1,
                   axis: simd_normalize(simd_double3(x: 1, y: 0, z: -1))),
        simd_quatd(angle: .pi * 0.15,
                   axis: simd_normalize(simd_double3(x: 0, y: 1, z: 0))),
        simd_quatd(angle: .pi * 0.2,
                   axis: simd_normalize(simd_double3(x: -1, y: 0, z: 1))),
        simd_quatd(angle: .pi * 0.15,
                   axis: simd_normalize(simd_double3(x: 0, y: -1, z: 0))),
        simd_quatd(angle: .pi * 0.1,
                   axis: simd_normalize(simd_double3(x: 1, y: 0, z: -1))),
        simd_quatd(angle: .pi * 0.05,
                   axis: simd_normalize(simd_double3(x: 0, y: 1, z: 0))),
        simd_quatd(angle: 0,
                   axis: simd_normalize(simd_double3(x: 0, y: 0, z: 1))),
        simd_quatd(angle: 0,
                   axis: simd_normalize(simd_double3(x: 0, y: 0, z: 1)))
    ]
    
    let cubeVertexOrigins: [simd_double3] = [
        simd_double3(x: -0.5, y: -0.5, z: 0.5),
        simd_double3(x: 0.5, y: -0.5, z: 0.5),
        simd_double3(x: -0.5, y: -0.5, z: -0.5),
        simd_double3(x: 0.5, y: -0.5, z: -0.5),
        simd_double3(x: -0.5, y: 0.5, z: 0.5),
        simd_double3(x: 0.5, y: 0.5, z: 0.5),
        simd_double3(x: -0.5, y: 0.5, z: -0.5),
        simd_double3(x: 0.5, y: 0.5, z: -0.5)
        ]
    
    lazy var cubeVertices = cubeVertexOrigins
   
    var vertexRotationIndex = 1
    var vertexRotationTime: Double = 0
    var previousCube: SCNNode?
    var previousVertexMarker: SCNNode?

    var displayLink: CADisplayLink!

    init() {
        scene = setupSceneKit()

        self.displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        
        displayLink.add(to: RunLoop.current, forMode: .default)
    }
    
    @objc private func displayLinkTick() {
        DispatchQueue.main.async {
            let cubeRotation = self
            cubeRotation.vertexRotationStep()
        }
    }
    
    public func vertexRotationStep() {

        previousCube?.removeFromParentNode()

        let increment: Double = 0.02
        vertexRotationTime += increment
        
        let quaternion: simd_quatd
        if useSpline {
            quaternion = simd_spline(
                vertexRotations[vertexRotationIndex - 1],
                vertexRotations[vertexRotationIndex],
                vertexRotations[vertexRotationIndex + 1],
                vertexRotations[vertexRotationIndex + 2],
                vertexRotationTime)
        } else {
            quaternion = simd_slerp(
                vertexRotations[vertexRotationIndex],
                vertexRotations[vertexRotationIndex + 1],
                vertexRotationTime)
        }

        previousVertexMarker?.removeFromParentNode()
        let vertex = cubeVertices[5]
        cubeVertices = cubeVertexOrigins.map {
            return quaternion.act($0)
        }

        previousVertexMarker = addSphereAt(position: cubeVertices[5],
                                           radius: 0.01,
                                           color: .red,
                                           scene: scene)

        addLineBetweenVertices(vertexA: vertex,
                               vertexB: cubeVertices[5],
                               inScene: scene,
                               color: .white)

        previousCube = addCube(vertices: cubeVertices,
                               inScene: scene)

        if vertexRotationTime >= 1 {
            vertexRotationIndex += 1
            vertexRotationTime = 0

            if vertexRotationIndex > vertexRotations.count - 3 {
                scene = setupSceneKit()
    
                vertexRotationIndex = 1
            }
        }
    }
}

