import SwiftUI
import RoyalVNCKit

struct ConfigurationView: View {
    @StateObject private var viewModel = ConfigurationViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("接続設定")) {
                    TextField("ホスト名", text: $viewModel.hostname)
                    TextField("ポート", text: $viewModel.port)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("オプション")) {
                    Toggle("共有接続", isOn: $viewModel.isShared)
                    Toggle("クリップボード転送", isOn: $viewModel.isClipboardRedirectionEnabled)
                    Toggle("スケーリング", isOn: $viewModel.isScalingEnabled)
                    Toggle("DisplayLink使用", isOn: $viewModel.useDisplayLink)
                    Toggle("デバッグログ", isOn: $viewModel.isDebugLoggingEnabled)
                }
                
                Section {
                    Button(action: {
                        if viewModel.isConnected {
                            viewModel.disconnect()
                        } else {
                            viewModel.connect()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.statusImage)
                            Text(viewModel.connectButtonText)
                        }
                    }
                    .disabled(!viewModel.connectButtonIsEnabled)
                    
                    if !viewModel.statusText.isEmpty {
                        Text(viewModel.statusText)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("VNC接続")
        }
        .sheet(isPresented: $viewModel.showCredentialView) {
            CredentialView(
                authenticationType: viewModel.authenticationType,
                previousUsername: viewModel.cachedUsername,
                previousPassword: viewModel.cachedPassword,
                completion: viewModel.handleCredentialCompletion
            )
        }
        .fullScreenCover(isPresented: $viewModel.showFramebufferView) {
            FramebufferView(
                framebuffer: viewModel.framebuffer,
                settings: viewModel.settings,
                connection: viewModel.connection,
                onDisconnect: viewModel.disconnect
            )
        }
    }
}

class ConfigurationViewModel: ObservableObject {
    @Published var hostname: String = ""
    @Published var port: String = "5900"
    @Published var isShared: Bool = false
    @Published var isClipboardRedirectionEnabled: Bool = false
    @Published var isScalingEnabled: Bool = false
    @Published var useDisplayLink: Bool = false
    @Published var isDebugLoggingEnabled: Bool = false
    
    @Published var statusText: String = ""
    @Published var statusImage: String = "stop"
    @Published var connectButtonText: String = "接続"
    @Published var connectButtonIsEnabled: Bool = true
    
    @Published var showCredentialView: Bool = false
    @Published var showFramebufferView: Bool = false
    
    @Published var authenticationType: VNCAuthenticationType?
    @Published var cachedUsername: String?
    @Published var cachedPassword: String?
    
    @Published var framebuffer: VNCFramebuffer?
    @Published var settings: VNCConnection.Settings?
    
    @Published var connection: VNCConnection?
    
    var isConnected: Bool {
        connection?.connectionState.status == .connected
    }
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        let settings = VNCConnection.Settings.fromUserDefaults()
        hostname = settings.hostname
        port = String(settings.port)
        isShared = settings.isShared
        isClipboardRedirectionEnabled = settings.isClipboardRedirectionEnabled
        isScalingEnabled = settings.isScalingEnabled
        useDisplayLink = settings.useDisplayLink
        isDebugLoggingEnabled = settings.isDebugLoggingEnabled
        cachedUsername = settings.cachedUsername
        cachedPassword = settings.cachedPassword
    }
    
    private func saveSettings() {
        let settings = VNCConnection.Settings(
            isDebugLoggingEnabled: isDebugLoggingEnabled,
            hostname: hostname,
            port: UInt16(port) ?? 5900,
            isShared: isShared,
            isScalingEnabled: isScalingEnabled,
            useDisplayLink: useDisplayLink,
            inputMode: .forwardAllKeyboardShortcutsAndHotKeys,
            isClipboardRedirectionEnabled: isClipboardRedirectionEnabled,
            colorDepth: .depth24Bit,
            frameEncodings: [.raw, .copyRect, .rre, .hextile, .zlib, .zrle]
        )
        settings.saveToUserDefaults()
        self.settings = settings
    }
    
    func connect() {
        saveSettings()
        
        let settings = VNCConnection.Settings(
            isDebugLoggingEnabled: isDebugLoggingEnabled,
            hostname: hostname,
            port: UInt16(port) ?? 5900,
            isShared: isShared,
            isScalingEnabled: isScalingEnabled,
            useDisplayLink: useDisplayLink,
            inputMode: .forwardAllKeyboardShortcutsAndHotKeys,
            isClipboardRedirectionEnabled: isClipboardRedirectionEnabled,
            colorDepth: .depth24Bit,
            frameEncodings: [.raw, .copyRect, .rre, .hextile, .zlib, .zrle]
        )
        
        let connection = VNCConnection(settings: settings)
        connection.delegate = self
        self.connection = connection
        self.settings = settings
        
        connection.connect()
    }
    
    func disconnect() {
        connection?.disconnect()
    }
    
    func handleCredentialCompletion(_ credential: VNCCredential?) {
        showCredentialView = false
        
        if let credential = credential {
            if let userPassCred = credential as? VNCUsernamePasswordCredential {
                if userPassCred.username != cachedUsername {
                    cachedUsername = userPassCred.username
                }
                if userPassCred.password != cachedPassword {
                    cachedPassword = userPassCred.password
                }
            } else if let passCred = credential as? VNCPasswordCredential {
                if passCred.password != cachedPassword {
                    cachedPassword = passCred.password
                }
            }
        }
    }
}

extension ConfigurationViewModel: VNCConnectionDelegate {
    func connection(_ connection: VNCConnection, stateDidChange connectionState: VNCConnection.ConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch connectionState.status {
            case .connecting:
                self.statusText = "接続中..."
                self.statusImage = "shuffle"
                self.connectButtonText = "切断"
                self.connectButtonIsEnabled = true
                
            case .disconnecting:
                self.statusText = "切断中..."
                self.statusImage = "shuffle"
                self.connectButtonText = "切断"
                self.connectButtonIsEnabled = false
                
            case .connected:
                self.statusText = "接続済み"
                self.statusImage = "play"
                self.connectButtonText = "切断"
                self.connectButtonIsEnabled = true
                
            case .disconnected:
                if let error = connectionState.error {
                    self.statusText = "エラーで切断: \(error.localizedDescription)"
                    self.statusImage = "exclamationmark.triangle"
                } else {
                    self.statusText = "切断済み"
                    self.statusImage = "stop"
                }
                self.connectButtonText = "接続"
                self.connectButtonIsEnabled = true
                self.showFramebufferView = false
                self.connection = nil
            }
        }
    }
    
    func connection(_ connection: VNCConnection, credentialFor authenticationType: VNCAuthenticationType, completion: @escaping (VNCCredential?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            self.authenticationType = authenticationType
            self.showCredentialView = true
        }
    }
    
    func connection(_ connection: VNCConnection, didCreateFramebuffer framebuffer: VNCFramebuffer) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.framebuffer = framebuffer
            self.showFramebufferView = true
        }
    }
    
    func connection(_ connection: VNCConnection, didResizeFramebuffer framebuffer: VNCFramebuffer) {
        // TODO: Implement framebuffer resize handling
    }
    
    func connection(_ connection: VNCConnection, didUpdateFramebuffer framebuffer: VNCFramebuffer, x: UInt16, y: UInt16, width: UInt16, height: UInt16) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.framebuffer = framebuffer
        }
    }
    
    func connection(_ connection: VNCConnection, didUpdateCursor cursor: VNCCursor) {
        // TODO: Implement cursor update handling
    }
} 
