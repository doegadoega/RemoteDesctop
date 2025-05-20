//
//  SSHClient.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import NMSSH

// SSHクライアントのラッパークラス
class SSHClient {
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
        connectionDelegate?.sshClientDidConnect(self)
        
        return true
    }
    
    func disconnect() {
        if isConnected, let session = session {
            session.disconnect()
            isConnected = false
            connectionDelegate?.sshClientDidDisconnect(self)
        }
    }
    
    // コマンドを実行するメソッド
    func executeCommand(_ command: String) throws -> String {
        guard isConnected, let session = session, session.isConnected, session.isAuthorized else {
            throw NSError(domain: "SSHClient", code: 1003, userInfo: [NSLocalizedDescriptionKey: "接続されていません"])
        }
        
        let response = session.channel.execute(command, error: nil)
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
        
        return session.channel.read()
    }
}

// SSH接続のデリゲートプロトコル
protocol SSHConnectionDelegate: AnyObject {
    func sshClientDidConnect(_ client: SSHClient)
    func sshClientDidDisconnect(_ client: SSHClient)
    func sshClient(_ client: SSHClient, didFailWithError error: Error)
    func sshClient(_ client: SSHClient, didReceiveOutput output: String)
}