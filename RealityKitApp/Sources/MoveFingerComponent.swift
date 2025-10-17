//
//  MoveFingerComponent.swift
//  RealityKitApp
//
//  Created by Marcos Bezerra on 29/09/25.
//
import RealityKit
import SwiftUI

public enum ArmIKState: String, Codable {
    case idle
    case reaching
    case rotating
}

@MainActor
public struct HandIKRuntimeComponent: Component {
    
    internal var currentState: ArmIKState = .idle
    internal var isIKEnabled: Bool = false
    internal var ikBlendTime: Float = 0.0
    private var initialized: Bool = false
    var transform: Transform?

    public init() {}

    public mutating func initialize(entity: Entity) {
        initializeIKComponent(entity: entity)
        initialized = true
    }

    private mutating func initializeIKComponent(entity: Entity) {
        if let modelEntity = findModelComponentEntity(entity: entity) {
            
            
            guard let modelSkeleton = modelEntity.components[ModelComponent.self]?.mesh.contents.skeletons.first else { return }

            var rig = try! IKRig(for: modelSkeleton)
            
            rig.maxIterations = 200
            
            
            
            rig.joints[Fingers.root]?.fkWeightPerAxis = [1, 1, 1]
            
            rig.joints[Fingers.pinky.jointName(.metacarpal)]?.fkWeightPerAxis = [1, 1, 1]
            rig.joints[Fingers.ring.jointName(.metacarpal)]?.fkWeightPerAxis = [1, 1, 1]
            rig.joints[Fingers.middle.jointName(.metacarpal)]?.fkWeightPerAxis = [1, 1, 1]
            rig.joints[Fingers.index.jointName(.metacarpal)]?.fkWeightPerAxis = [0.6, 1, 1]
            rig.joints[Fingers.thumb.jointName(.metacarpal)]?.fkWeightPerAxis = [1, 1, 1]
            
            
            rig.joints[Fingers.index.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.index.jointName(.middle)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.index.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
//            rig.joints[Fingers.index.jointName(.proximal)]?.limits = .init(
//                weight: 1.0,
//                boneAxis: .x,
//                minimumAngles: [-90.radian,
//                                 -90.radian,
//                                 -90.radian],
//                maximumAngles: [90.radian,
//                                90.radian,
//                                90.radian]
//            )
            
            rig.constraints = [
               
                .point(named: "index.metacarpal",
                       on: Fingers.index.jointName(.metacarpal),
                       positionWeight: [0, 0, 0]),
                
                .parent(named: "index.proximal",
                       on: Fingers.index.jointName(.proximal),
                       orientationWeight: [1,0,0]),
                
                .parent(named: "index.middle",
                       on: Fingers.index.jointName(.middle),
                       orientationWeight: [1,1,1]),
                
                .parent(
                    named: "index.distal",
                    on: Fingers.index.jointName(.distal),
                    orientationWeight: [1,1,1])
            ]
            
            let resource = try! IKResource(rig: rig)
            modelEntity.components.set(IKComponent(resource: resource))
            
        }
    }


    private func findModelComponentEntity(entity: Entity) -> Entity? {
        if entity.components[ModelComponent.self] != nil {
            return entity
        }
        for child in entity.children {
            if let found = findModelComponentEntity(entity: child) {
                return found
            }
        }
        return nil
    }
}

@MainActor
public class HandIKSystem: System {
    
    
    private static let query = EntityQuery(where: .has(HandIKRuntimeComponent.self))
    
    public required init(scene: RealityKit.Scene) {}
    
    public func elipsesToJoints(ikComponent: IKComponent) -> [Entity] {
        
        return []
    }

    public func update(context: SceneUpdateContext) {
        
        context.scene.performQuery(Self.query).forEach { entity in
            
            if let _ = entity.components[HandIKRuntimeComponent.self] {
                let ikComp = entity.components[IKComponent.self]!
                
                let rotation: simd_quatf = .init(angle: 200.radian, axis: [1,0,0])
                
                
                ikComp.solvers[0].constraints["index.proximal"]!.target = Transform (
                    rotation: .init(angle: 180.radian, axis: [1,0,0])
                )
                
                ikComp.solvers[0].constraints["index.middle"]!.target = Transform (
                    rotation: rotation
                )
                
                ikComp.solvers[0].constraints["index.distal"]!.target = Transform (
                    rotation: rotation,
                    translation: [0,-0.9,0]
                    
                )
                
                ikComp.solvers[0].constraints["index.distal"]!.animationOverrideWeight = (position: 0, rotation: 0)
                ikComp.solvers[0].constraints["index.middle"]!.animationOverrideWeight.rotation = 0
                ikComp.solvers[0].constraints["index.proximal"]!.animationOverrideWeight.rotation = 1
                
                entity.components.set(ikComp)
                
            
            }
        }
    }
}



extension Int {
    var radian: Float {
        Float(self) * .pi / 180
    }
}
