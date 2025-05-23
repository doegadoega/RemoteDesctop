// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteDesctop",
    platforms: [
        .macOS(.v12),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RemoteDesctop",
            targets: ["RemoteDesctop"]),
    ],
    dependencies: [
        // SSH接続用ライブラリ
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssh.git", from: "0.1.0"),
        
        // VNC接続用ライブラリ
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5"),
        .package(url: "https://github.com/royalapplications/royalvnc.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RemoteDesctop",
            dependencies: [
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSH", package: "swift-nio-ssh"),
                .product(name: "RoyalVNCKit", package: "royalvnc"),
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