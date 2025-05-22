//
//  SSHClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import Citadel
import NIO

// SSHクライアントの実装クラス
class SSHClientImplementation: SSHClient {
    private var hostname: String
    private var port: Int
    private var username: String
    private var password: String
    
    private var isConnected = false
    private weak var connectionDelegate: SSHConnectionDelegate?
    
    // Citadel関連のプロパティ
    private var eventLoopGroup: MultiThreadedEventLoopGroup?
    private var connection: SSHClient.Connection?
    private var shell: SSHClient.Shell?
    
    override init(hostname: String, port: Int, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        super.init(hostname: hostname, port: port, username: username, password: password)
    }
    
    override func setDelegate(_ delegate: SSHConnectionDelegate) {
        self.connectionDelegate = delegate
        super.setDelegate(delegate)
    }
    
    override func connect() async throws -> Bool {
        do {
            // イベントループグループを作成
            eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            
            guard let eventLoopGroup = eventLoopGroup else {
                throw SSHClientError.notConnected
            }
            
            // SSHクライアントを作成
            let client = Citadel.SSHClient(
                userInfo: .init(username: username),
                hostInfo: .init(hostname: hostname, port: port),
                hostKeyValidator: .acceptAnything(),
                reconnect: .none
            )
            
            // 接続を確立
            connection = try await client.connect(on: eventLoopGroup.next())
            
            // パスワード認証
            try await connection?.authenticate(.password(password))
            
            // シェルを開く
            shell = try await connection?.requestShell()
            
            // シェルの出力を処理
            shell?.output.whenOutput { [weak self] data in
                guard let self = self else { return }
                let output = String(buffer: data)
                DispatchQueue.main.async {
                    self.connectionDelegate?.sshClient(self, didReceiveOutput: output)
                }
            }
            
            // 接続成功
            isConnected = true
            connectionDelegate?.sshClientDidConnect(self)
            connectionDelegate?.sshClient(self, didReceiveOutput: "Connected to \(hostname):\(port) as \(username)")
            
            return true
        } catch {
            // 接続失敗
            await cleanup()
            connectionDelegate?.sshClient(self, didFailWithError: error)
            return false
        }
    }
    
    override func disconnect() {
        Task {
            await cleanup()
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionDelegate?.sshClientDidDisconnect(self)
            }
        }
    }
    
    private func cleanup() async {
        // シェルを閉じる
        try? await shell?.close()
        shell = nil
        
        // 接続を閉じる
        try? await connection?.close()
        connection = nil
        
        // イベントループグループをシャットダウン
        try? await eventLoopGroup?.shutdownGracefully()
        eventLoopGroup = nil
    }
    
    // コマンド実行メソッド
    func executeCommand(_ command: String) async throws -> String {
        guard isConnected, let shell = shell else {
            throw SSHClientError.notConnected
        }
        
        // コマンドを実行
        try await shell.write(command + "\n")
        
        // 実行結果を返す（実際には非同期で出力が処理される）
        return "Command sent: \(command)"
    }
}
