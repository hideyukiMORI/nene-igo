// swift-tools-version: 6.2
// tools-version は manifest の API の版であり、ツールチェーンの版（.swift-version）ではない。
// 6.2 は treatAllWarnings(as:) を使える最小の版（ADR 0001）。
// target は承認された依存グラフ（docs/architecture/module-graph.txt・ADR 0004）から、最初の責務が生じた PR で足す（Core は Issue #3、ほかは Issue #5）。
// 各 target の swiftSettings は [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]（CNF-009）。

import PackageDescription

let package = Package(
    name: "NeNeIgo",
    targets: [
        .target(
            name: "NeNeIgoCore",
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeIgoEngine",
            dependencies: ["NeNeIgoCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeIgoRender",
            dependencies: ["NeNeIgoCore", "NeNeIgoEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeIgoTerminal",
            dependencies: ["NeNeIgoRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .executableTarget(
            name: "nene-igo",
            dependencies: ["NeNeIgoCore", "NeNeIgoEngine", "NeNeIgoRender", "NeNeIgoTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeIgoCoreTests",
            dependencies: ["NeNeIgoCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeIgoEngineTests",
            dependencies: ["NeNeIgoCore", "NeNeIgoEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeIgoRenderTests",
            dependencies: ["NeNeIgoCore", "NeNeIgoEngine", "NeNeIgoRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeIgoTerminalTests",
            dependencies: ["NeNeIgoRender", "NeNeIgoTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
