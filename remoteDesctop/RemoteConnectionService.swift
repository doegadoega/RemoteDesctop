//
//  RemoteConnectionService.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import SwiftUI

// SPMを使用した実装
class RemoteConnectionService: NSObject, RDPConnectionDelegate, AppVNCClientDelegate, SSHConnectionDelegate {
    static let shared = RemoteConnectionService()
    
    private var rdpClient: RDPClient?
    private var vncClient: VNCClient?
    private var sshClient: SSHClient?
    
    private var activeConnection: RemoteConnection?
    private var connectionCompletion: ((Bool, Error?) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func connect(to connection: RemoteConnection) async throws -> Bool {
        activeConnection = connection
        
        switch connection.connectionType {
        case .rdp:
            return try await connectRDP(connection)
        case .vnc:
            return try await connectVNC(connection)
        case .ssh:
            return try await connectSSH(connection)
        }
    }
    
    private func connectRDP(_ connection: RemoteConnection) async throws -> Bool {
        // RDPClientImplementationを使用
        rdpClient = RDPClientImplementation(
            hostname: connection.hostname,
            port: connection.port,
            username: connection.username,
            password: connection.password
        )
        
        rdpClient?.setDelegate(self)
        return try await rdpClient?.connect() ?? false
    }
    
    private func connectVNC(_ connection: RemoteConnection) async throws -> Bool {
        // VNCClientを使用
        vncClient = VNCClient(
            hostname: connection.hostname,
            port: connection.port,
            username: connection.username,
            password: connection.password
        )
        
        vncClient?.setDelegate(self)
        vncClient?.connect()
        // connect()はasync throwsではなくなったので、trueを返す
        return true
    }
    
    private func connectSSH(_ connection: RemoteConnection) async throws -> Bool {
        // SSHClientImplementationを使用
        sshClient = SSHClientImplementation(
            hostname: connection.hostname,
            port: connection.port,
            username: connection.username,
            password: connection.password
        )
        
        sshClient?.setDelegate(self)
        return try await sshClient?.connect() ?? false
    }
    
    func disconnect() {
        rdpClient?.disconnect()
        vncClient?.disconnect()
        sshClient?.disconnect()
        
        rdpClient = nil
        vncClient = nil
        sshClient = nil
        activeConnection = nil
    }
    
    func getDefaultPort(for connectionType: ConnectionType) -> Int {
        switch connectionType {
        case .rdp:
            return 3389
        case .vnc:
            return 5900
        case .ssh:
            return 22
        }
    }
    
    func validateConnection(_ connection: RemoteConnection) -> Bool {
        // Basic validation
        guard !connection.hostname.isEmpty else { return false }
        guard connection.port > 0 else { return false }
        
        return true
    }
    
    // MARK: - RDPConnectionDelegate
    
    func rdpClientDidConnect(_ client: RDPClient) {
        print("RDP client connected")
    }
    
    func rdpClientDidDisconnect(_ client: RDPClient) {
        print("RDP client disconnected")
    }
    
    func rdpClient(_ client: RDPClient, didFailWithError error: Error) {
        print("RDP client error: \(error.localizedDescription)")
    }
    
    func rdpClient(_ client: RDPClient, didUpdateFrame image: Data) {
        // 画面更新の処理
        print("RDP screen updated: \(String(data: image, encoding: .utf8) ?? "No data")")
    }
    
    // MARK: - VNCConnectionDelegate
    
    func vncClientDidConnect(_ client: VNCClient) {
        print("VNC client connected")
    }
    
    func vncClientDidDisconnect(_ client: VNCClient) {
        print("VNC client disconnected")
    }
    
    func vncClient(_ client: VNCClient, didFailWithError error: Error) {
        print("VNC client error: \(error.localizedDescription)")
    }
    
    func vncClient(_ client: VNCClient, didUpdateFrame image: Data) {
        // 画面更新の処理
        print("VNC screen updated: \(String(data: image, encoding: .utf8) ?? "No data")")
    }
    
    // MARK: - SSHConnectionDelegate
    
    func sshClientDidConnect(_ client: SSHClient) {
        print("SSH client connected")
    }
    
    func sshClientDidDisconnect(_ client: SSHClient) {
        print("SSH client disconnected")
    }
    
    func sshClient(_ client: SSHClient, didFailWithError error: Error) {
        print("SSH client error: \(error.localizedDescription)")
    }
    
    func sshClient(_ client: SSHClient, didReceiveOutput output: String) {
        print("SSH output: \(output)")
    }
}
