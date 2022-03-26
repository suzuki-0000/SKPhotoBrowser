// swift-tools-version:5.3
//
//  Package.swift
//

import PackageDescription

let package = Package(
    name: "SKPhotoBrowser",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "SKPhotoBrowser",
            targets: ["SKPhotoBrowser"])
    ],
    targets: [
        .target(
            name: "SKPhotoBrowser",
            dependencies: [],
            path: "SKPhotoBrowser",
            exclude: ["SKPhotoBrowser.bundle","Info.plist"],
            resources: [.process("SKPhotoBrowser.bundle/images")])
    ]
)
