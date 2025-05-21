//
//  SSHClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation

// SSHクライアントの実装クラス
class SSHClientImplementation: SSHClient {
    private var hostname: String
    private var port: Int
    private var username: String
    private var password: String
    
    private var isConnected = false
    private weak var connectionDelegate: SSHConnectionDelegate?
    
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
            // 実際の実装では、SSHライブラリを使用して接続
            // ここではシミュレーションのみ
            
            // 接続プロセスをシミュレート - 非同期処理を使用せずに即時返す
            // 実際の実装では、ここで適切な接続処理を行う
            
            // コマンド実行結果をシミュレート
            let result = "Connected to \(hostname):\(port) as \(username)"
            
            // 接続成功をシミュレート
            isConnected = true
            connectionDelegate?.sshClientDidConnect(self)
            connectionDelegate?.sshClient(self, didReceiveOutput: result)
            
            return true
        } catch {
            connectionDelegate?.sshClient(self, didFailWithError: error)
            return false
        }
    }
    
    override func disconnect() {
        if isConnected {
            isConnected = false
            connectionDelegate?.sshClientDidDisconnect(self)
        }
    }
    
    // コマンド実行メソッド
    func executeCommand(_ command: String) async throws -> String {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        // 実際の実装では、SSHセッションを通じてコマンドを実行
        // ここではシミュレーションのみ
        
        // コマンド実行をシミュレート - 非同期処理を使用せずに即時返す
        // 実際の実装では、ここで適切なコマンド実行処理を行う
        
        // 実行結果をシミュレート
        let result = "Output of '\(command)' on \(hostname):\n$ \(command)\nSimulated command output."
        
        // デリゲートに通知
        connectionDelegate?.sshClient(self, didReceiveOutput: result)
        
        return result
    }
}
