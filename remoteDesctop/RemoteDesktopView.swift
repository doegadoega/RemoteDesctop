//
//  RemoteDesktopView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI

struct RemoteDesktopView: View {
    @Environment(\.dismiss) private var dismiss
    
    let connection: RemoteConnection
    
    @State private var isConnecting = false
    @State private var isConnected = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    @State private var keyboardVisible = false
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            if isConnecting {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView("接続中...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("\(connection.name) (\(connection.hostname):\(connection.port))")
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                }
            } else if isConnected {
                // リモートデスクトップ表示エリア
                ZStack {
                    // 実際の実装では、ここにリモートデスクトップの画面が表示される
                    Rectangle()
                        .fill(Color.black)
                        .overlay(
                            VStack {
                                Image(systemName: "desktopcomputer")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .padding()
                                Text("リモートデスクトップ画面")
                                    .foregroundColor(.white)
                            }
                        )
                    
                    // 接続情報を表示
                    VStack {
                        Spacer()
                        HStack {
                            Text("\(connection.name) (\(connection.hostname):\(connection.port))")
                                .font(.caption)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            Spacer()
                        }
                    }
                    .padding()
                }
                
                // コントロールパネル
                HStack {
                    Button(action: {
                        keyboardVisible.toggle()
                    }) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 20))
                            .padding()
                    }
                    
                    Spacer()
                    
                    // マウスモードボタン
                    Button(action: {
                        // マウスモード切替
                    }) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 20))
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        disconnect()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 20))
                            .padding()
                    }
                }
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                
                // キーボード入力エリア
                if keyboardVisible {
                    VStack {
                        TextField("テキスト入力", text: $inputText)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(8)
                        
                        Button("送信") {
                            sendKeyboardInput()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .transition(.move(edge: .bottom))
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("接続に失敗しました")
                        .font(.headline)
                        .padding()
                    
                    Button("再接続") {
                        connect()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button("戻る") {
                        dismiss()
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(isConnected)
        .navigationTitle(connection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isConnected {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("切断") {
                        disconnect()
                    }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "不明なエラーが発生しました")
        }
        .onAppear {
            connect()
        }
        .onDisappear {
            disconnect()
        }
    }
    
    private func connect() {
        isConnecting = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await RemoteConnectionService.shared.connect(to: connection)
                
                await MainActor.run {
                    isConnecting = false
                    isConnected = success
                    
                    if !success {
                        errorMessage = "接続に失敗しました"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                    isConnected = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func disconnect() {
        RemoteConnectionService.shared.disconnect()
        isConnected = false
        dismiss()
    }
    
    private func sendKeyboardInput() {
        // キーボード入力を送信
        print("Sending keyboard input: \(inputText)")
        inputText = ""
        keyboardVisible = false
    }
}