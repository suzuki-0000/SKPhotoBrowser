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
            dependencies: ["SKPhotoBrowserObjC"],
            path: "SKPhotoBrowser",
            exclude: ["Info.plist",
                      "extensions/ObjC"],
            resources: [
                .copy("SKPhotoBrowser.bundle")
            ]),
        .target(
            name: "SKPhotoBrowserObjC",
            path: "SKPhotoBrowser/extensions/ObjC",
            publicHeadersPath: "."),
        .testTarget(
            name: "SKPhotoBrowserTests",
            dependencies: ["SKPhotoBrowser"],
            path: "SKPhotoBrowserTests",
            exclude: ["Info.plist"]
        )
    ]
)
