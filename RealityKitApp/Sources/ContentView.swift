import SwiftUI
import RealityKit

public struct ContentView: View {
    @State var angle: Float = 0
    
    public var body: some View {
        VStack {
            Text("\(angle)º")
            
            RealityView { content in
                let scene = HandSceneFactory.makeHandScene()
                content.add(scene)
                
                _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    guard let hand = Skeleton.shared.hand else { return }
                    
                    angle += 0.5
                    
                    let rotationX = simd_quatf(
                        angle: -degreesToRadian(90),
                        axis: [1, 0, 0]
                    )
                    
                    let rotationY = simd_quatf(
                        angle: -degreesToRadian(angle),
                        axis: [0, 1, 0]
                    )
                    
                    hand.transform.rotation = rotationY * rotationX
                    hand.transform.scale = [0.6, 0.6, 0.6]
                }

            }
        }
        .onAppear {
            animateFingersSequence()
        }
    }
    
    func animateFingersSequence() {
        Task { @MainActor in
            guard let hand = Skeleton.shared.hand else { return }
            
            try await Task.sleep(nanoseconds: UInt64(0.5 * 2_000_000_000))
            SkeletalComponent.updateFingerPose(entity: hand, finger: .thumb, angle: 1.2)
            
            try await Task.sleep(nanoseconds: UInt64(0.5 * 2_000_000_000))
            SkeletalComponent.updateFingerPose(entity: hand, finger: .index, angle: 1.2)
            
            try await Task.sleep(nanoseconds: UInt64(0.5 * 2_000_000_000))
            SkeletalComponent.updateFingerPose(entity: hand, finger: .middle, angle: 1.2)
            
            try await Task.sleep(nanoseconds: UInt64(0.5 * 2_000_000_000))
            SkeletalComponent.updateFingerPose(entity: hand, finger: .ring, angle: 1.2)
            
            try await Task.sleep(nanoseconds: UInt64(0.5 * 2_000_000_000))
            SkeletalComponent.updateFingerPose(entity: hand, finger: .pinky, angle: 1.2)
        }
    }
}

private extension ContentView {
    func degreesToRadian(_ degree: Float) -> Float {
        degree * Float.pi / 180
    }
}
