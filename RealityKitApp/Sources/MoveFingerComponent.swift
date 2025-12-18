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

// Estrutura para configuração de um dedo
public struct FingerIKConfig {
    var proximalRotation: simd_quatf
    var middleRotation: simd_quatf
    var distalRotation: simd_quatf
    var weight: Float // 0 = animação, 1 = IK total
    
    static let relaxed = FingerIKConfig(
        proximalRotation: simd_quatf(angle: 0, axis: [1, 0, 0]),
        middleRotation: simd_quatf(angle: 0, axis: [1, 0, 0]),
        distalRotation: simd_quatf(angle: 0, axis: [1, 0, 0]),
        weight: 0
    )
    
    static let curled = FingerIKConfig(
        proximalRotation: simd_quatf(angle: -.pi / 3, axis: [1, 0, 0]),
        middleRotation: simd_quatf(angle: -.pi / 2.5, axis: [1, 0, 0]),
        distalRotation: simd_quatf(angle: -.pi / 3, axis: [1, 0, 0]),
        weight: 1.0
    )
    
    static let pointing = FingerIKConfig(
        proximalRotation: simd_quatf(angle: -.pi / 8, axis: [1, 0, 0]),
        middleRotation: simd_quatf(angle: -.pi / 6, axis: [1, 0, 0]),
        distalRotation: simd_quatf(angle: -.pi / 8, axis: [1, 0, 0]),
        weight: 0.8
    )
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
            
            // CONFIGURAÇÃO DOS METACARPAIS (base dos dedos)
            // Valores mais altos = mais rígidos, seguem mais a animação FK
            rig.joints[Fingers.root]?.fkWeightPerAxis = [1, 1, 1]
            
            // Metacarpais com peso médio para permitir algum movimento
            rig.joints[Fingers.pinky.jointName(.metacarpal)]?.fkWeightPerAxis = [0.8, 1, 1]
            rig.joints[Fingers.ring.jointName(.metacarpal)]?.fkWeightPerAxis = [0.8, 1, 1]
            rig.joints[Fingers.middle.jointName(.metacarpal)]?.fkWeightPerAxis = [0.7, 1, 1]
            rig.joints[Fingers.index.jointName(.metacarpal)]?.fkWeightPerAxis = [0.6, 1, 1]
            rig.joints[Fingers.thumb.jointName(.metacarpal)]?.fkWeightPerAxis = [1, 1, 1]
            
            // CONFIGURAÇÃO DAS FALANGES - Controle total por IK
            // [0, 0, 0] = IK total, sem influência da animação FK
            
            // Indicador
            rig.joints[Fingers.index.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.index.jointName(.middle)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.index.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
            // Médio
            rig.joints[Fingers.middle.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.middle.jointName(.middle)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.middle.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
            // Anelar
            rig.joints[Fingers.ring.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.ring.jointName(.middle)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.ring.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
            // Mindinho
            rig.joints[Fingers.pinky.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.pinky.jointName(.middle)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.pinky.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
            // Polegar (só tem 2 falanges)
            rig.joints[Fingers.thumb.jointName(.proximal)]?.fkWeightPerAxis = [0, 0, 0]
            rig.joints[Fingers.thumb.jointName(.distal)]?.fkWeightPerAxis = [0, 0, 0]
            
            // CONSTRAINTS - Define como cada junta deve se comportar
            rig.constraints = [
                .parent(named: "index.proximal", on: Fingers.index.jointName(.proximal), orientationWeight: [1, 1, 1]),
                .parent(named: "index.middle", on: Fingers.index.jointName(.middle), orientationWeight: [1, 1, 1]),
                .parent(named: "index.distal", on: Fingers.index.jointName(.distal), orientationWeight: [1, 1, 1]),
                
                .parent(named: "middle.proximal", on: Fingers.middle.jointName(.proximal), orientationWeight: [1, 1, 1]),
                .parent(named: "middle.middle", on: Fingers.middle.jointName(.middle), orientationWeight: [1, 1, 1]),
                .parent(named: "middle.distal", on: Fingers.middle.jointName(.distal), orientationWeight: [1, 1, 1]),
                
                .parent(named: "ring.proximal", on: Fingers.ring.jointName(.proximal), orientationWeight: [1, 1, 1]),
                .parent(named: "ring.middle", on: Fingers.ring.jointName(.middle), orientationWeight: [1, 1, 1]),
                .parent(named: "ring.distal", on: Fingers.ring.jointName(.distal), orientationWeight: [1, 1, 1]),
                
                .parent(named: "pinky.proximal", on: Fingers.pinky.jointName(.proximal), orientationWeight: [1, 1, 1]),
                .parent(named: "pinky.middle", on: Fingers.pinky.jointName(.middle), orientationWeight: [1, 1, 1]),
                .parent(named: "pinky.distal", on: Fingers.pinky.jointName(.distal), orientationWeight: [1, 1, 1]),
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

    public func update(context: SceneUpdateContext) {
        
        context.scene.performQuery(Self.query).forEach { entity in
            guard var ikComp = entity.components[IKComponent.self],
                  let runtimeComp = entity.components[HandIKRuntimeComponent.self],
                  let solver = ikComp.solvers.first else { return }
            
            // TODO: Pode adicionar solvers

            entity.components.set(ikComp)
        }
    }
    
    private func applyFingerConfig(solver: IKComponent.Solver, fingerPrefix: String, config: FingerIKConfig) {
        // Define as rotações alvo
        solver.constraints["\(fingerPrefix).proximal"]?.target = Transform(rotation: config.proximalRotation)
        solver.constraints["\(fingerPrefix).middle"]?.target = Transform(rotation: config.middleRotation)
        solver.constraints["\(fingerPrefix).distal"]?.target = Transform(rotation: config.distalRotation)
        
        // Define o peso de override (quanto o IK sobrescreve a animação)
        solver.constraints["\(fingerPrefix).proximal"]?.animationOverrideWeight.rotation = config.weight
        solver.constraints["\(fingerPrefix).middle"]?.animationOverrideWeight.rotation = config.weight
        solver.constraints["\(fingerPrefix).distal"]?.animationOverrideWeight.rotation = config.weight
    }
}

