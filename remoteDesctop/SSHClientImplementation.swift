//
//  SSHClientImplementation.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import NIO
import NIOSSH

// SSHクライアントの実装クラス
class SSHClientImplementation: SSHClient {
    private var isConnected = false
    private weak var connectionDelegate: SSHConnectionDelegate?
    
    // NIO関連のプロパティ
    private var eventLoopGroup: MultiThreadedEventLoopGroup?
    private var channel: Channel?
    
    override init(hostname: String, port: Int, username: String, password: String) {
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
            
            // SSHクライアントの設定
            let configuration = SSHClientConfiguration(
                userAuthDelegate: PasswordAuthenticationDelegate(username: username, password: password),
                serverAuthDelegate: AcceptAllHostKeysDelegate()
            )
            
            // 接続を確立
            let bootstrap = ClientBootstrap(group: eventLoopGroup)
                .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandlers([
                        NIOSSHHandler(
                            role: .client(configuration),
                            allocator: ByteBufferAllocator(),
                            inboundChildChannelInitializer: nil
                        ),
                        SSHClientSessionHandler(delegate: self.connectionDelegate)
                    ])
                }
            
            channel = try await bootstrap.connect(host: hostname, port: port).get()
            
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
        // チャンネルを閉じる
        try? await channel?.close()
        channel = nil
        
        // イベントループグループをシャットダウン
        try? await eventLoopGroup?.shutdownGracefully()
        eventLoopGroup = nil
    }
    
    override func executeCommand(_ command: String) async throws -> String {
        guard isConnected, let channel = channel else {
            throw SSHClientError.notConnected
        }
        // コマンド送信例（実際の実装はHandlerで出力を受け取る必要あり）
        let execRequest = SSHChannelRequestEvent.ExecRequest(command: command, wantReply: true)
        try await channel.triggerUserOutboundEvent(execRequest).get()
        return "Command sent: \(command)"
    }
}

// MARK: - SSH Authentication

private class PasswordAuthenticationDelegate: NIOSSHClientUserAuthenticationDelegate {
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        if availableMethods.contains(.password) {
            nextChallengePromise.succeed(
                .init(
                    username: username,
                    serviceName: "ssh-connection",
                    offer: .password(.init(password: password))
                )
            )
        } else {
            nextChallengePromise.succeed(nil)
        }
    }
}

private class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        validationCompletePromise.succeed(())
    }
}

private class SSHClientSessionHandler: ChannelInboundHandler {
    typealias InboundIn = SSHChannelData
    typealias OutboundOut = SSHChannelData
    
    private weak var delegate: SSHConnectionDelegate?
    
    init(delegate: SSHConnectionDelegate?) {
        self.delegate = delegate
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // 出力データの処理
        let channelData = unwrapInboundIn(data)
        if case .byteBuffer(let buffer) = channelData.data {
            let output = String(buffer: buffer)
            delegate?.sshClient(self as! SSHClient, didReceiveOutput: output)
            print("SSH Output: \(output)")
        }
    }
}
