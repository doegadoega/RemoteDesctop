//
//  ConnectionDetailView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData

struct ConnectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let connection: RemoteConnection
    
    @State private var isConnecting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingEditSheet = false
    @State private var navigateToRemoteDesktop = false
    
    var body: some View {
        List {
            Section(header: Text("Connection Details")) {
                LabeledContent("Name", value: connection.name)
                LabeledContent("Hostname", value: connection.hostname)
                LabeledContent("Port", value: "\(connection.port)")
                LabeledContent("Type", value: connection.connectionType.rawValue)
            }
            
            Section(header: Text("Authentication")) {
                LabeledContent("Username", value: connection.username)
                LabeledContent("Password", value: "••••••••")
            }
            
            if let lastConnected = connection.lastConnected {
                Section(header: Text("Connection History")) {
                    LabeledContent("Last Connected", value: lastConnected.formatted(date: .long, time: .shortened))
                }
            }
            
            Section {
                Button(action: connectToRemoteDesktop) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Connect")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(isConnecting)
            }
        }
        .navigationTitle(connection.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .overlay {
            if isConnecting {
                ProgressView("Connecting...")
                    .padding()
                    .background(Color.secondary.colorInvert().opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditConnectionView(connection: connection)
        }
        .navigationDestination(isPresented: $navigateToRemoteDesktop) {
            RemoteDesktopView(connection: connection)
        }
    }
    
    private func connectToRemoteDesktop() {
        // 接続画面に遷移
        connection.lastConnected = Date()
        navigateToRemoteDesktop = true
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: RemoteConnection.self, configurations: config)
        let example = RemoteConnection(
            name: "Test Server",
            hostname: "192.168.1.100",
            port: 3389,
            username: "admin",
            password: "password",
            connectionType: .rdp,
            lastConnected: Date()
        )
        
        return NavigationStack {
            ConnectionDetailView(connection: example)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}