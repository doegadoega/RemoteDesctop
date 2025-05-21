//
//  VNCClient.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation

// MARK: - VNC接続のデリゲートプロトコル
protocol AppVNCClientDelegate: AnyObject {
    func vncClientDidConnect(_ client: VNCClient)
    func vncClientDidDisconnect(_ client: VNCClient)
    func vncClient(_ client: VNCClient, didFailWithError error: Error)
    func vncClient(_ client: VNCClient, didUpdateFrame image: Data)
}

// MARK: - 実装
class VNCClient: NSObject {
    private let hostname: String
    private let port: Int
    private let password: String

    private var isConnected = false
    private weak var connectionDelegate: AppVNCClientDelegate?

    private var updateTimer: Timer?

    init(hostname: String, port: Int, password: String) {
        self.hostname = hostname
        self.port = port
        self.password = password
    }

    func setDelegate(_ delegate: AppVNCClientDelegate) {
        self.connectionDelegate = delegate
    }

    func connect() async throws -> Bool {
        // 実際の実装では、VNCライブラリを使用して接続
        // ここではシミュレーションのみ
        
        // 接続成功をシミュレート
        isConnected = true
        connectionDelegate?.vncClientDidConnect(self)
        
        // 画面更新のシミュレーション開始
        startScreenUpdates()
        
        return true
    }

    func disconnect() {
        guard isConnected else { return }
        stopScreenUpdates()
        isConnected = false
        connectionDelegate?.vncClientDidDisconnect(self)
    }

    func sendKeyboardInput(_ text: String) {
        guard isConnected else { return }
        
        // 実際の実装では、VNCプロトコルを通じてリモートサーバーにキーボード入力を送信
        print("Sending keyboard input: \(text)")
    }

    func sendMouseEvent(x: Int, y: Int, isClick: Bool) {
        guard isConnected else { return }
        
        // 実際の実装では、VNCプロトコルを通じてリモートサーバーにマウスイベントを送信
        print("Mouse event: x=\(x), y=\(y), isClick=\(isClick)")
    }

    func getScreenCapture() -> Data {
        // 実際の実装では、VNCからのフレームデータを処理してデータに変換
        // ここではダミーデータを生成
        let dummyText = "VNC Screen: \(hostname):\(port)"
        return dummyText.data(using: .utf8) ?? Data()
    }

    private func startScreenUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let imageData = self.getScreenCapture()
            self.connectionDelegate?.vncClient(self, didUpdateFrame: imageData)
        }
    }

    private func stopScreenUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
