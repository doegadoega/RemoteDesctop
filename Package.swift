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
        // SSH接続用ライブラリ
        .package(url: "https://github.com/NMSSH/NMSSH.git", from: "2.3.1"),
        
        // VNC接続用ライブラリ
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", from: "7.6.5"),
        
        // RDP接続用ライブラリ（代替として使用可能なオープンソースライブラリ）
        .package(url: "https://github.com/TigerVNC/tigervnc.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "RemoteDesctop",
            dependencies: [
                .product(name: "NMSSH", package: "NMSSH"),
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
                // TigerVNCはSwift Package Managerで直接サポートされていないため、カスタムビルドが必要
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