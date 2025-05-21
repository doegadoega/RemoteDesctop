//
//  VNCClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import UIKit
import CocoaAsyncSocket
import EasyVNC

// VNCクライアントの実装
// SPMを使用した実装例

// VNCクライアントのプロトコル
protocol VNCClientProtocol {
    func connect() async throws -> Bool
    func disconnect()
    func sendKeyboardInput(_ text: String)
    func sendMouseEvent(x: Int, y: Int, isClick: Bool)
    func getScreenCapture() -> UIImage?
}

// VNCクライアントの実装クラス
class VNCClientImplementation: NSObject, VNCClientProtocol {
    private var hostname: String
    private var port: Int
    private var password: String
    
    private var vncClient: VNCClientManager?
    private var isConnected = false
    private var connectionDelegate: VNCConnectionDelegate?
    
    // 画面更新用のタイマー
    private var updateTimer: Timer?
    
    init(hostname: String, port: Int, password: String) {
        self.hostname = hostname
        self.port = port
        self.password = password
        super.init()
    }
    
    func setDelegate(_ delegate: VNCConnectionDelegate) {
        self.connectionDelegate = delegate
    }
    
    func connect() async throws -> Bool {
        // EasyVNCを使用してVNC接続を確立
        vncClient = VNCClientManager(host: hostname, port: UInt16(port), password: password)
        
        do {
            // 接続を開始
            try vncClient?.connect()
            
            // 接続プロセスをシミュレート（実際の接続は非同期で行われる）
            try await Task.sleep(for: .seconds(2))
            
            // 接続成功をシミュレート
            isConnected = true
            connectionDelegate?.vncClientDidConnect(self)
            
            // 画面更新のシミュレーション
            startScreenUpdates()
            
            return true
        } catch {
            connectionDelegate?.vncClient(self, didFailWithError: error)
            return false
        }
    }
    
    func disconnect() {
        if isConnected {
            stopScreenUpdates()
            vncClient?.disconnect()
            isConnected = false
            connectionDelegate?.vncClientDidDisconnect(self)
        }
    }
    
    func sendKeyboardInput(_ text: String) {
        guard isConnected, let vncClient = vncClient else { return }
        
        // EasyVNCを使用してキーボード入力を送信
        for char in text {
            vncClient.sendKey(char)
        }
    }
    
    func sendMouseEvent(x: Int, y: Int, isClick: Bool) {
        guard isConnected, let vncClient = vncClient else { return }
        
        // EasyVNCを使用してマウスイベントを送信
        if isClick {
            vncClient.sendMouseClick(x: Int32(x), y: Int32(y), button: 1) // 左クリック
        } else {
            vncClient.sendMouseMove(x: Int32(x), y: Int32(y))
        }
    }
    
    func getScreenCapture() -> UIImage? {
        guard isConnected, let vncClient = vncClient else { return nil }
        
        // EasyVNCから最新のフレームを取得
        if let frameData = vncClient.getCurrentFrame() {
            return UIImage(data: frameData)
        }
        
        // フレームが取得できない場合はダミー画像を生成
        let size = CGSize(width: 800, height: 600)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // 背景色を設定
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // テキストを描画
        let text = "VNC Connection to \(hostname):\(port)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.label
        ]
        
        let textSize = (text as NSString).size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 画面更新のシミュレーション
    private func startScreenUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let image = self.getScreenCapture() else { return }
            self.connectionDelegate?.vncClient(self, didUpdateFrame: image)
        }
    }
    
    private func stopScreenUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}