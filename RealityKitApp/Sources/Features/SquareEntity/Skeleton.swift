//
//  Square.swift
//  RealityKitApp
//
//  Created by Marcos Bezerra on 26/09/25.
//

import SwiftUI
import RealityKit


class Skeleton {
    let baseEntity: Entity?
    let hand: ModelEntity?
    
    init() {
        self.baseEntity = try? Entity.load(named: "Hand-v1.0")
        self.hand = baseEntity?.findEntity(named: "Armature") as? ModelEntity
    }
    
//    let entity: Entity = {
//        let mesh = MeshResource.generateSphere(radius: 0.5)
//        
//        let material = SimpleMaterial(color: .red, isMetallic: true)
//        let component = ModelComponent(mesh: mesh, materials: [material])
//        let entity = Entity()
//        entity.components.set(component)
//        entity.position.x = 0
//        entity.position.y = -0.4
//        entity.position.z = 0
//        entity.transform.scale.x = 0.2
//        entity.transform.scale.y = 0.2
//        entity.transform.scale.z = 0.2
//        return entity
//    }()
}


