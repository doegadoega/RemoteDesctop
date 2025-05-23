//
//  EditConnectionView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData
import RoyalVNCKit

struct EditConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var connection: RemoteConnection
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Connection Details") {
                    TextField("Name", text: $connection.name)
                    TextField("Hostname", text: $connection.hostname)
                    TextField("Port", value: $connection.port, format: .number)
                        .keyboardType(.numberPad)
                    TextField("Username", text: $connection.username)
                    SecureField("Password", text: $connection.password)
                    Picker("Type", selection: $connection.connectionType) {
                        Text("RDP").tag(ConnectionType.rdp)
                        Text("VNC").tag(ConnectionType.vnc)
                        Text("SSH").tag(ConnectionType.ssh)
                    }
                }
            }
            .navigationTitle("Edit Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                    .disabled(connection.name.isEmpty || connection.hostname.isEmpty)
                }
            }
        }
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
            connectionType: .rdp
        )
        
        return EditConnectionView(connection: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}