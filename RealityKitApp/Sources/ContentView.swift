import SwiftUI
import RealityKit

public struct ContentView: View {
    @State var angle: Float = 0
    
    public var body: some View {
        VStack {
            Text("\(angle)º")
            RealityView { content in
                
                HandIKSystem.registerSystem()
                
                let skeleton = Skeleton()
                guard let hand = skeleton.hand else { fatalError("Could not add hand entity") }
                hand.position.y -= 0.9
                
                var runtime = HandIKRuntimeComponent()
                
                let lineY = lineBetween([2,0,0], [-2,0,0], color: .green)
                let lineX = lineBetween([0,2,0], [0,-2,0])
                let lineZ = lineBetween([0,0,8], [0,0,-4], color: .cyan)
                
                
                addLabelToLine(line: lineX,
                               end: (text: "x+",
                                     position: [0,1,0],
                                     color: .red),
                               start: (text: "x-",
                                       position: [0,-1,0],
                                       color: .red))
                addLabelToLine(line: lineY,
                                end: (text: "y+",
                                      position: [0,1,0],
                                      color: .green),
                                start: (text: "y-",
                                        position: [0,-1,0],
                                        color: .green))
            
                runtime.initialize(entity: hand)
                
                
                hand.components.set(runtime)
                content.add(hand)
                
                hand.addChild(lineX)
                hand.addChild(lineY)
                hand.addChild(lineZ)
                
                _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    angle += 0.5
                    let rotationX = simd_quatf(angle: -degreesToRadian(90), axis: [1,0,0]) // 90° em X
                    let rotationY = simd_quatf(angle: -degreesToRadian(angle), axis: [0,1,0]) // 90° em Y
                    
                    let combinedRotation = rotationY * rotationX
                    hand.transform.rotation = combinedRotation
                    hand.transform.scale.x = 0.6
                    hand.transform.scale.y = 0.6
                    hand.transform.scale.z = 0.6
                    
                }
            }
        }
    }
    
    func addLabelToLine(line: ModelEntity,
                        end: (text: String, position:SIMD3<Float>, color: UIColor),
                        start: (text: String, position:SIMD3<Float>, color: UIColor)) {
        let startEntity: ModelEntity = {
            ModelEntity(
                mesh: .generateText(start.text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1)),
                materials: [SimpleMaterial(color: start.color, isMetallic: false)]
            )}()
        
        let endEntity: ModelEntity = {
            ModelEntity(
                mesh: .generateText(end.text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1)),
                materials: [SimpleMaterial(color: end.color, isMetallic: false)]
            )}()
        
        line.addChild(startEntity)
        line.addChild(endEntity)
        
        startEntity.transform.translation = start.position
        
        endEntity.transform.translation = end.position
        
    }
    
    func lineBetween(_ start: SIMD3<Float>, _ end: SIMD3<Float>, color: UIColor = .red) -> ModelEntity {
        // Create thin box
        let line = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(0.005, 1, 0.005)),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )

        // Direction and rotation
        let direction = simd_normalize(end - start)
        let defaultAxis = SIMD3<Float>(0, 1, 0)
        let rotation = simd_quatf(from: defaultAxis, to: direction)

        // Apply transform
        line.position = (start + end) / 2
        line.transform.rotation = rotation
        line.scale.y = simd_distance(start, end) / 2

        return line
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


private extension ContentView {
    private func degreesToRadian(_ degree: Float) -> Float{
        return degree * Float.pi / 180
    }
}
