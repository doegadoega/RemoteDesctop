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

class SSHClient {
    // private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let hostname: String
    private let port: Int
    private let username: String
    private let password: String
    private var isConnected = false
    private weak var connectionDelegate: SSHConnectionDelegate?

    init(hostname: String, port: Int, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
    }
    
    func setDelegate(_ delegate: SSHConnectionDelegate) {
        self.connectionDelegate = delegate
    }
    
    func connect() async throws -> Bool {
        do {
            // シンプルなコマンドを実行して接続テスト
            let result = try await connectAndExecute(command: "echo Connected")
            isConnected = true
            connectionDelegate?.sshClientDidConnect(self)
            connectionDelegate?.sshClient(self, didReceiveOutput: result)
            return true
        } catch {
            connectionDelegate?.sshClient(self, didFailWithError: error)
            return false
        }
    }
    
    func disconnect() {
        if isConnected {
            isConnected = false
            connectionDelegate?.sshClientDidDisconnect(self)
        }
    }

    func connectAndExecute(command: String) async throws -> String {
        // 実際の実装では、SSHライブラリを使用して接続し、コマンドを実行
        // ここではシミュレーションのみ
        
        // 接続プロセスをシミュレート - 非同期処理を使用せずに即時返す
        // 実際の実装では、ここで適切な接続処理を行う
        
        // コマンド実行結果をシミュレート
        return "Simulated output for command: \(command)"
    }
}

// MARK: - SSH Error

enum SSHClientError: Error {
    case notConnected
    case invalidChannelType
    case noResultPromise
}
