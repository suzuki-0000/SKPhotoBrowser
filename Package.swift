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
            targets: ["UIImageAnimatedGIF", "SKPhotoBrowser"])
    ],
    targets: [
        .target(
            name: "UIImageAnimatedGIF",
            path: "SKPhotoBrowser/extensions",
            exclude: ["UIApplication+UIWindow.swift", "UIImage+Rotation.swift", "UIView+Radius.swift"]
        ),
        .target(
            name: "SKPhotoBrowser",
            dependencies: ["UIImageAnimatedGIF"],
            path: "SKPhotoBrowser",
            exclude: ["Info.plist", "extensions/UIImage+animatedGIF.h", "extensions/UIImage+animatedGIF.m"],
            resources: [
                .copy("SKPhotoBrowser.bundle")
            ]
        )
    ]
)
