//
//  SkeletalComponent.swift
//  RealityKitApp
//
//  Created by Yasmin Carloto Bezerra da Silva on 03/12/25.
//

import RealityKit

@MainActor
public struct SkeletalComponent: Component {
    var initialized = false

    public init() {}

    public mutating func initialize(entity: Entity) {
        initializeSkeletalComponent(entity: entity)
        initialized = true
    }

    private mutating func initializeSkeletalComponent(entity: Entity) {
        if let modelEntity = SkeletalComponent.findModelComponentEntity(entity: entity),
           var skeletalComponent = modelEntity.components[SkeletalPosesComponent.self],
           let pose = skeletalComponent.poses.default {
            var newPose = pose
            
//            if let index = pose.jointNames.firstIndex(of: Fingers.pinky.jointName(.middle)) {
//                var jointTransform = newPose.jointTransforms[index]
//                let angle: Float = Float(2.14) // dobra 45º
//                jointTransform.rotation = simd_quatf(angle: angle, axis: [1, 0, 0])
//                    
//                newPose.jointTransforms[index] = jointTransform
//                    
//                skeletalComponent.poses.default = newPose
//                    
//                modelEntity.components.set(skeletalComponent)
//            }
//            
//            if let index = pose.jointNames.firstIndex(of: Fingers.ring.jointName(.middle)) {
//                var jointTransform = newPose.jointTransforms[index]
//                let angle: Float = Float(2.14)
//                jointTransform.rotation = simd_quatf(angle: angle, axis: [1, 0, 0])
//                    
//                newPose.jointTransforms[index] = jointTransform
//                    
//                skeletalComponent.poses.default = newPose
//                    
//                modelEntity.components.set(skeletalComponent)
//            }
        }
    }

    private static func findModelComponentEntity(entity: Entity) -> Entity? {
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
    
    // TODO: Criar função para modificar posição das juntas
    // TODO: Criar função para modificar posição do metacarpo principal (pulso)
    // TODO: Limitar movimentação dos dedos, ou seja, impedir movimentos que não existem em uma mão real.
    // TODO: Fazer exceção para dedão (que mexe em outro eixo)
    public static func updateFingerPose(entity: Entity, finger: Fingers, angle: Float) {
        guard let modelEntity = findModelComponentEntity(entity: entity),
              var skeletalComponent = modelEntity.components[SkeletalPosesComponent.self],
              let pose = skeletalComponent.poses.default else {
            return
        }

        var newPose = pose

        for jointFullName in finger.jointPathList() {

            if let index = pose.jointNames.firstIndex(of: jointFullName) {
                var jointTransform = newPose.jointTransforms[index]
                jointTransform.rotation = simd_quatf(angle: angle, axis: [1, 0, 0])
                newPose.jointTransforms[index] = jointTransform
            }
            
            skeletalComponent.poses.default = newPose
            modelEntity.components.set(skeletalComponent)
        }
    }

}

@MainActor
public class SkeletonSystem: System {

    private static let query = EntityQuery(where: .has(SkeletalComponent.self))

    public required init(scene: RealityKit.Scene) {}

    public func update(context: SceneUpdateContext) {

        context.scene.performQuery(Self.query).forEach { entity in
            print(entity)
            if let component = entity.components[SkeletalPosesComponent.self] {

            }
        }
    }

    func applyFingerPose() {

    }
}

extension SkeletalComponent {

}
