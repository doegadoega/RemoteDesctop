// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteDesctop",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RemoteDesctop",
            targets: ["RemoteDesctop"]),
    ],
    dependencies: [
        // SSH接続用ライブラリ - NIOSSHベースのCitadelを使用
        .package(url: "https://github.com/orlandos-nl/Citadel.git", from: "0.10.0"),
        
        // VNC接続用ライブラリ
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5"),
        
        // VNCクライアント実装
        .package(url: "https://github.com/iOmega8561/EasyVNC.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RemoteDesctop",
            dependencies: [
                .product(name: "Citadel", package: "Citadel"),
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
                .product(name: "EasyVNC", package: "EasyVNC"),
            ],
            path: "remoteDesctop"
        ),
        .testTarget(
            name: "RemoteDesctopTests",
            dependencies: ["RemoteDesctop"],
            path: "remoteDesctopTests"
        ),
    ]
)