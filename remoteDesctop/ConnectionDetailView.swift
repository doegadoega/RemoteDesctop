//
//  ConnectionDetailView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData

@available(macOS 14.0, *)
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
        Form {
            Section("Connection Details") {
                LabeledContent("Name", value: connection.name)
                LabeledContent("Hostname", value: connection.hostname)
                LabeledContent("Port", value: String(connection.port))
                LabeledContent("Username", value: connection.username)
                LabeledContent("Type", value: connection.connectionType.rawValue)
            }
            
            Section("Connection History") {
                if let lastConnected = connection.lastConnected {
                    LabeledContent("Last Connected", value: lastConnected.formatted())
                }
                LabeledContent("Created", value: connection.createdAt.formatted())
            }
            
            Section {
                Button("Connect") {
                    connectToRemoteDesktop()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(connection.name)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showingEditSheet = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditConnectionView(connection: connection)
        }
    }
    
    private func connectToRemoteDesktop() {
        connection.lastConnected = Date()
        navigateToRemoteDesktop = true
    }
}

@available(macOS 14.0, *)
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