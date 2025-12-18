//
//  HandSceneFactory.swift
//  RealityKitApp
//
//  Created by Yasmin Carloto Bezerra da Silva on 09/12/25.
//

import RealityKit
import SwiftUI

public struct HandSceneFactory {

    @MainActor static func makeHandScene() -> Entity {
        let root = Entity()

        // MARK: - Load Hand
//        let skeleton = Skeleton()
        guard let hand = Skeleton.shared.hand else {
            fatalError("Could not load hand entity")
        }
        hand.position.y -= 0.9
        
        // MARK: - IK + Skeletal Components
        // Runtime serve para que aconteça uma animação. Sem ele, vemos uma pose estática.
//        var runtime = HandIKRuntimeComponent()
        var skeletalComponent = SkeletalComponent()
//        runtime.initialize(entity: hand)
        skeletalComponent.initialize(entity: hand)

        // MARK: - Axes
        let lineX = lineBetween([0, 2, 0], [0, -2, 0], color: .red)
        let lineY = lineBetween([2, 0, 0], [-2, 0, 0], color: .green)
        let lineZ = lineBetween([0, 0, 8], [0, 0, -4], color: .cyan)

        addLabelToLine(line: lineX, end: ("x+", [0, 1, 0], .red), start: ("x-", [0, -1, 0], .red))
        addLabelToLine(line: lineY, end: ("y+", [0, 1, 0], .green), start: ("y-", [0, -1, 0], .green))
        addLabelToLine(line: lineZ, end: ("z+", [0, 1, 0], .cyan), start: ("z-", [0, -1, 0], .cyan))

        hand.addChild(lineX)
        hand.addChild(lineY)
        hand.addChild(lineZ)

        root.addChild(hand)
        return root
    }
}

// MARK: - Helpers

private func addLabelToLine(
    line: ModelEntity,
    end: (text: String, position: SIMD3<Float>, color: UIColor),
    start: (text: String, position: SIMD3<Float>, color: UIColor)
) {
    let startEntity = ModelEntity(
        mesh: .generateText(start.text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1)),
        materials: [SimpleMaterial(color: start.color, isMetallic: false)]
    )
    
    let endEntity = ModelEntity(
        mesh: .generateText(end.text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1)),
        materials: [SimpleMaterial(color: end.color, isMetallic: false)]
    )
    
    line.addChild(startEntity)
    line.addChild(endEntity)

    startEntity.position = start.position
    endEntity.position = end.position
}

private func lineBetween(_ start: SIMD3<Float>, _ end: SIMD3<Float>, color: UIColor = .red) -> ModelEntity {
    let line = ModelEntity(
        mesh: .generateBox(size: SIMD3<Float>(0.005, 1, 0.005)),
        materials: [SimpleMaterial(color: color, isMetallic: false)]
    )
    
    let direction = simd_normalize(end - start)
    let defaultAxis = SIMD3<Float>(0, 1, 0)
    let rotation = simd_quatf(from: defaultAxis, to: direction)

    line.position = (start + end) / 2
    line.transform.rotation = rotation
    line.scale.y = simd_distance(start, end) / 2

    return line
}
