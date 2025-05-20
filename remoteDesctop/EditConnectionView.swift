//
//  EditConnectionView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData

struct EditConnectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let connection: RemoteConnection
    
    @State private var name: String
    @State private var hostname: String
    @State private var port: String
    @State private var username: String
    @State private var password: String
    @State private var connectionType: ConnectionType
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(connection: RemoteConnection) {
        self.connection = connection
        _name = State(initialValue: connection.name)
        _hostname = State(initialValue: connection.hostname)
        _port = State(initialValue: String(connection.port))
        _username = State(initialValue: connection.username)
        _password = State(initialValue: connection.password)
        _connectionType = State(initialValue: connection.connectionType)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Connection Details")) {
                    TextField("Name", text: $name)
                    TextField("Hostname/IP Address", text: $hostname)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Authentication")) {
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                }
                
                Section(header: Text("Connection Type")) {
                    Picker("Type", selection: $connectionType) {
                        Text("Remote Desktop").tag(ConnectionType.rdp)
                        Text("VNC").tag(ConnectionType.vnc)
                        Text("SSH").tag(ConnectionType.ssh)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Edit Connection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConnection()
                    }
                }
            }
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func saveConnection() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a name for the connection"
            showingAlert = true
            return
        }
        
        guard !hostname.isEmpty else {
            alertMessage = "Please enter a hostname or IP address"
            showingAlert = true
            return
        }
        
        guard let portNumber = Int(port), portNumber > 0 else {
            alertMessage = "Please enter a valid port number"
            showingAlert = true
            return
        }
        
        // Update the connection properties
        connection.name = name
        connection.hostname = hostname
        connection.port = portNumber
        connection.username = username
        connection.password = password
        connection.connectionType = connectionType
        
        dismiss()
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