import ProjectDescription
let bundleId = "com.locahost.RealityKitApp"
let project = Project(
    name: "RealityKitApp",
    targets: [
        .target(
            name: "RealityKitApp",
            destinations: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["RealityKitApp/Sources/**"],
            resources: ["RealityKitApp/Resources/**"],
            dependencies: []
        )
    ]
)
