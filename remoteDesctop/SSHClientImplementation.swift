//
//  SSHClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import Citadel
import NIO

// SSHクライアントの実装
// SPMを使用した実装例

// SSHクライアントのプロトコル
protocol SSHClientProtocol {
    func connect() async throws -> Bool
    func disconnect()
    func executeCommand(_ command: String) async throws -> String
    func startShell() async throws
    func writeToShell(_ command: String) async throws
    func readFromShell() async throws -> String
}

// SSHクライアントの実装クラス
class SSHClientImplementation: SSHClientProtocol {
    private var hostname: String
    private var port: Int
    private var username: String
    private var password: String
    
    private var client: SSHClient?
    private var isConnected = false
    private var connectionDelegate: SSHConnectionDelegate?
    private var shell: SSHChannel?
    
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
        // Citadelを使用してSSH接続を確立
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        do {
            client = try await SSHClient.connect(
                host: hostname,
                port: port,
                username: username,
                authenticationMethod: .passwordBased(password: password),
                hostKeyValidator: .acceptUnknownHostKeys,
                on: eventLoopGroup
            ).get()
            
            isConnected = true
            connectionDelegate?.sshClientDidConnect(self)
            
            return true
        } catch {
            throw NSError(domain: "SSHClient", code: 1001, userInfo: [NSLocalizedDescriptionKey: "接続に失敗しました: \(error.localizedDescription)"])
        }
    }
    
    func disconnect() {
        if isConnected, let client = client {
            try? client.close().wait()
            isConnected = false
            connectionDelegate?.sshClientDidDisconnect(self)
        }
    }
    
    // コマンドを実行するメソッド
    func executeCommand(_ command: String) async throws -> String {
        guard isConnected, let client = client else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        do {
            let result = try await client.executeCommand(command).get()
            connectionDelegate?.sshClient(self, didReceiveOutput: result)
            return result
        } catch {
            throw NSError(domain: "SSHClient", code: 1004, userInfo: [NSLocalizedDescriptionKey: "コマンド実行に失敗しました: \(error.localizedDescription)"])
        }
    }
    
    // シェルを開始するメソッド
    func startShell() async throws {
        guard isConnected, let client = client else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        do {
            shell = try await client.openShell().get()
        } catch {
            throw NSError(domain: "SSHClient", code: 1005, userInfo: [NSLocalizedDescriptionKey: "シェルの開始に失敗しました: \(error.localizedDescription)"])
        }
    }
    
    // シェルにコマンドを送信するメソッド
    func writeToShell(_ command: String) async throws {
        guard isConnected, let shell = shell else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "シェルが開始されていません"])
        }
        
        do {
            try await shell.write(command).get()
        } catch {
            throw NSError(domain: "SSHClient", code: 1006, userInfo: [NSLocalizedDescriptionKey: "シェルへの書き込みに失敗しました: \(error.localizedDescription)"])
        }
    }
    
    // シェルからの出力を読み取るメソッド
    func readFromShell() async throws -> String {
        guard isConnected, let shell = shell else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "シェルが開始されていません"])
        }
        
        do {
            let data = try await shell.read().get()
            let output = String(data: data, encoding: .utf8) ?? ""
            connectionDelegate?.sshClient(self, didReceiveOutput: output)
            return output
        } catch {
            throw NSError(domain: "SSHClient", code: 1007, userInfo: [NSLocalizedDescriptionKey: "シェルからの読み取りに失敗しました: \(error.localizedDescription)"])
        }
    }
}