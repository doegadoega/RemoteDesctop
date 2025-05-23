//
//  VNCClient.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import RoyalVNCKit
import UIKit

// MARK: - VNC接続のデリゲートプロトコル
protocol AppVNCClientDelegate: AnyObject {
    func vncClientDidConnect(_ client: VNCClient)
    func vncClientDidDisconnect(_ client: VNCClient)
    func vncClient(_ client: VNCClient, didFailWithError error: Error)
    func vncClient(_ client: VNCClient, didUpdateFrame image: Data)
}

// MARK: - 実装
class VNCClient: NSObject {
    var settings: VNCConnection.Settings
    var userName: String?
    var password: String = ""
    
    var credential: VNCCredential {
        if let userName {
            return VNCUsernamePasswordCredential(username: userName,
                                                 password: self.password)
        }
        return VNCPasswordCredential(password: self.password)
    }
    
    private var connection: VNCConnection?
    private weak var connectionDelegate: AppVNCClientDelegate?
    private(set) var framebufferView: VNCFramebufferView?

    init(hostname: String, port: Int, username: String, password: String) {
        self.settings = VNCConnection.Settings(isDebugLoggingEnabled: true,
                                          hostname: hostname,
                                          port: UInt16(port),
                                          isShared: false,
                                          isScalingEnabled: true,
                                          useDisplayLink: true,
                                          inputMode: .forwardAllKeyboardShortcutsAndHotKeys,
                                          isClipboardRedirectionEnabled: true,
                                          colorDepth: .depth16Bit,
                                          frameEncodings: .default)
    }

    func setDelegate(_ delegate: AppVNCClientDelegate) {
        self.connectionDelegate = delegate
    }

    func connect() {
        self.connection = VNCConnection(settings: self.settings)
        self.connection?.delegate = self
        self.connection?.connect()
    }

    func disconnect() {
        self.connection?.disconnect()
        self.connection = nil
        connectionDelegate?.vncClientDidDisconnect(self)
        framebufferView = nil
    }

    func sendKeyboardInput(_ text: String) {
        // RoyalVNCKitのAPIでキーボード入力送信（必要に応じて実装）
    }

    func sendMouseEvent(x: Int, y: Int, isClick: Bool) {
        // RoyalVNCKitのAPIでマウスイベント送信（必要に応じて実装）
    }

    func getScreenCapture() -> Data {
        if let connect = self.connection,
           let framebuffer = connect.framebuffer,
            let cgImage = framebuffer.cgImage {
            let image = UIImage(cgImage: cgImage)
            return image.pngData() ?? Data()
        }
        return Data()
    }
}

extension VNCClient: VNCConnectionDelegate {
    func connection(_ connection: RoyalVNCKit.VNCConnection, stateDidChange connectionState: RoyalVNCKit.VNCConnection.ConnectionState) {
     
        switch connectionState.status {
        case .connecting:
            self.connectionDelegate?.vncClientDidConnect(self)
        case .disconnected:
            self.destroyConnection()
            self.destroyFramebufferView()
        default:
            break
        }
    }
    
    func connection(_ connection: RoyalVNCKit.VNCConnection, credentialFor authenticationType: RoyalVNCKit.VNCAuthenticationType, completion: @escaping ((any RoyalVNCKit.VNCCredential)?) -> Void) {
        
    }
    
    func connection(_ connection: RoyalVNCKit.VNCConnection, didCreateFramebuffer framebuffer: RoyalVNCKit.VNCFramebuffer) {
        
    }
    
    func connection(_ connection: RoyalVNCKit.VNCConnection, didResizeFramebuffer framebuffer: RoyalVNCKit.VNCFramebuffer) {
        
    }
    
    func connection(_ connection: RoyalVNCKit.VNCConnection, didUpdateFramebuffer framebuffer: RoyalVNCKit.VNCFramebuffer, x: UInt16, y: UInt16, width: UInt16, height: UInt16) {
        
    }
    
    func connection(_ connection: RoyalVNCKit.VNCConnection, didUpdateCursor cursor: RoyalVNCKit.VNCCursor) {
        
    }
}

private extension VNCClient {
    /// Connection削除
    func destroyConnection() {
        connection?.delegate = nil
        connection = nil
    }
    
    /// フレームバッファ削除
    private func destroyFramebufferView() {
//        guard let framebufferViewController = framebufferViewController
//        else {
//            return
//        }
//        framebufferViewController.framebufferViewControllerDelegate = nil
//        framebufferViewController.dismiss(animated: true)
    }
}
