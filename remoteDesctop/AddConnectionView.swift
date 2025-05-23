//
//  AddConnectionView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData

struct AddConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var hostname = ""
    @State private var port = 3389
    @State private var username = ""
    @State private var password = ""
    @State private var connectionType = ConnectionType.rdp
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Connection Details") {
                    TextField("Name", text: $name)
                    TextField("Hostname", text: $hostname)
                    TextField("Port", value: $port, format: .number)
                        .keyboardType(.numberPad)
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                    Picker("Type", selection: $connectionType) {
                        Text("RDP").tag(ConnectionType.rdp)
                        Text("VNC").tag(ConnectionType.vnc)
                        Text("SSH").tag(ConnectionType.ssh)
                    }
                }
            }
            .navigationTitle("Add Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addConnection()
                    }
                    .disabled(name.isEmpty || hostname.isEmpty)
                }
            }
        }
    }
    
    private func addConnection() {
        let connection = RemoteConnection(
            name: name,
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            connectionType: connectionType
        )
        modelContext.insert(connection)
        dismiss()
    }
}

#Preview {
    AddConnectionView()
        .modelContainer(for: RemoteConnection.self, inMemory: true)
}
