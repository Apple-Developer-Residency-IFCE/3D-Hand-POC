//
//  ContentOld.swift
//  RealityKitApp
//
//  Created by Marcos Bezerra on 28/09/25.
//

import SwiftUI
import RealityKit

public struct ContentOldView: View {


    public var body: some View {
        
            
            RealityView { content in
                
                let square = Skeleton()
                let entity = try! await Entity(named: "skeleton")
                
                if let armature = entity.findEntity(named: "Armature") {
                    armature.position.x = -0.2
                    armature.position.y -= 1.3
                    
                    armature.transform.rotation = simd_quatf(angle: -(Float.pi / 2), axis: [1,0,0])
                    
                    
                    
                    armature.transform.scale.x = 0.1
                    armature.transform.scale.y = 0.1
                    armature.transform.scale.z = 0.1
                    
                    
                    content.add(armature)
                }
        }
    }
}


struct ContentOldView_Previews: PreviewProvider {
    static var previews: some View {
        ContentOldView()
    }
}
