//
//  SSHClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import NMSSH

// SSHクライアントの実装
// SPMを使用した実装例

// SSHクライアントのプロトコル
protocol SSHClientProtocol {
    func connect() async throws -> Bool
    func disconnect()
    func executeCommand(_ command: String) throws -> String
    func startShell() throws
    func writeToShell(_ command: String) throws
    func readFromShell() throws -> String
}

// SSHクライアントの実装クラス
class SSHClientImplementation: SSHClientProtocol {
    private var hostname: String
    private var port: Int
    private var username: String
    private var password: String
    
    private var session: NMSSHSession?
    private var isConnected = false
    private var connectionDelegate: SSHConnectionDelegate?
    
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
        // NMSSHを使用してSSH接続を確立
        session = NMSSHSession(host: hostname, port: port, andUsername: username)
        
        guard let session = session else {
            throw NSError(domain: "SSHClient", code: 1000, userInfo: [NSLocalizedDescriptionKey: "セッションの作成に失敗しました"])
        }
        
        session.connect()
        
        if !session.isConnected {
            throw NSError(domain: "SSHClient", code: 1001, userInfo: [NSLocalizedDescriptionKey: "接続に失敗しました"])
        }
        
        // パスワード認証
        session.authenticate(byPassword: password)
        
        if !session.isAuthorized {
            throw NSError(domain: "SSHClient", code: 1002, userInfo: [NSLocalizedDescriptionKey: "認証に失敗しました"])
        }
        
        isConnected = true
        connectionDelegate?.sshClientDidConnect(self as! SSHClient)
        
        return true
    }
    
    func disconnect() {
        if isConnected, let session = session {
            session.disconnect()
            isConnected = false
            connectionDelegate?.sshClientDidDisconnect(self as! SSHClient)
        }
    }
    
    // コマンドを実行するメソッド
    func executeCommand(_ command: String) throws -> String {
        guard isConnected, let session = session, session.isConnected, session.isAuthorized else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        let response = session.channel.execute(command, error: nil)
        connectionDelegate?.sshClient(self as! SSHClient, didReceiveOutput: response)
        return response
    }
    
    // シェルを開始するメソッド
    func startShell() throws {
        guard isConnected, let session = session, session.isConnected, session.isAuthorized else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        try session.channel.startShell()
    }
    
    // シェルにコマンドを送信するメソッド
    func writeToShell(_ command: String) throws {
        guard isConnected, let session = session, session.isConnected, session.isAuthorized else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        try session.channel.write(command)
    }
    
    // シェルからの出力を読み取るメソッド
    func readFromShell() throws -> String {
        guard isConnected, let session = session, session.isConnected, session.isAuthorized else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        let output = session.channel.read()
        connectionDelegate?.sshClient(self as! SSHClient, didReceiveOutput: output)
        return output
    }
}