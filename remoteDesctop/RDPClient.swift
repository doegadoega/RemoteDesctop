//
//  RDPClient.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation

// MARK: - RDP接続のデリゲートプロトコル
protocol RDPConnectionDelegate: AnyObject {
    func rdpClientDidConnect(_ client: RDPClient)
    func rdpClientDidDisconnect(_ client: RDPClient)
    func rdpClient(_ client: RDPClient, didFailWithError error: Error)
    func rdpClient(_ client: RDPClient, didUpdateFrame image: Data)
}

// MARK: - 実装
class RDPClient {
    private let hostname: String
    private let port: Int
    private let username: String
    private let password: String
    
    private var isConnected = false
    private weak var connectionDelegate: RDPConnectionDelegate?
    
    init(hostname: String, port: Int, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
    }
    
    func setDelegate(_ delegate: RDPConnectionDelegate) {
        self.connectionDelegate = delegate
    }
    
    func connect() async throws -> Bool {
        // 実際の実装では、RDPライブラリを使用して接続
        // ここではシミュレーションのみ
        
        // 接続成功をシミュレート
        isConnected = true
        connectionDelegate?.rdpClientDidConnect(self)
        
        // 画面更新のシミュレーション開始
        startScreenUpdates()
        
        return true
    }
    
    func disconnect() {
        guard isConnected else { return }
        stopScreenUpdates()
        isConnected = false
        connectionDelegate?.rdpClientDidDisconnect(self)
    }
    
    func sendKeyboardInput(_ text: String) {
        guard isConnected else { return }
        
        // 実際の実装では、RDPプロトコルを通じてリモートサーバーにキーボード入力を送信
        print("Sending keyboard input: \(text)")
    }
    
    func sendMouseEvent(x: Int, y: Int, isClick: Bool) {
        guard isConnected else { return }
        
        // 実際の実装では、RDPプロトコルを通じてリモートサーバーにマウスイベントを送信
        print("Mouse event: x=\(x), y=\(y), isClick=\(isClick)")
    }
    
    func getScreenCapture() -> Data {
        guard isConnected else { return Data() }
        
        // 実際の実装では、RDPからのフレームデータを処理してデータに変換
        // ここではダミーデータを生成
        let dummyText = "RDP Screen: \(hostname):\(port)"
        return dummyText.data(using: .utf8) ?? Data()
    }
    
    private var updateTimer: Timer?
    
    private func startScreenUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let imageData = self.getScreenCapture()
            self.connectionDelegate?.rdpClient(self, didUpdateFrame: imageData)
        }
    }
    
    private func stopScreenUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
