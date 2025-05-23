//
//  SSHClient.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
// 注: 実際のSSH実装には、NIOSSHやLibSSHなどのライブラリを使用する必要があります
// import NIO
// import NIOSSH

// SSHConnectionDelegateの定義はSSHConnectionDelegate.swiftに集約

enum SSHClientError: Error {
    case notConnected
    case invalidCredentials
    case connectionFailed
    // 必要ならここに他のエラーケースを追加
}

class SSHClient {
    // private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let hostname: String
    let port: Int
    let username: String
    let password: String
    private var isConnected = false
    weak var delegate: SSHConnectionDelegate?

    init(hostname: String, port: Int, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
    }
    
    func setDelegate(_ delegate: SSHConnectionDelegate) {
        self.delegate = delegate
    }
    
    func connect() async throws -> Bool {
        fatalError("connect() must be implemented by subclass")
    }
    
    func disconnect() {
        fatalError("disconnect() must be implemented by subclass")
    }
    
    func executeCommand(_ command: String) async throws -> String {
        fatalError("executeCommand() must be implemented by subclass")
    }
}

// MARK: - SSH Error

// ここに他のエラー定義が必要な場合はSSHClientErrorにまとめてください
