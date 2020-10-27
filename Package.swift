// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Ripples",
    products: [
        .library(name: "Ripples", targets: ["Ripples"])
    ],
    targets: [
        .target(
            name: "Ripples",
            dependencies: [],
            exclude:["Example","Ripples"]
        )
    ]
)
