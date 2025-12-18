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
    var hand: ModelEntity?
    public static let shared = Skeleton()
    
    private init() {
        self.baseEntity = try? Entity.load(named: "Hand-v1.0")
        self.hand = baseEntity?.findEntity(named: "Armature") as? ModelEntity
    }
}


