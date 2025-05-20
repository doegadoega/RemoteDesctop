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
    
    @State private var name: String = ""
    @State private var hostname: String = ""
    @State private var port: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var connectionType: ConnectionType = .rdp {
        didSet {
            if oldValue != connectionType {
                port = "\(RemoteConnectionService.shared.getDefaultPort(for: connectionType))"
            }
        }
    }
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Connection Details")) {
                    TextField("Name", text: $name)
                    TextField("Hostname/IP Address", text: $hostname)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                        .onAppear {
                            if port.isEmpty {
                                port = "\(RemoteConnectionService.shared.getDefaultPort(for: connectionType))"
                            }
                        }
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
            .navigationTitle("Add Connection")
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
        
        let connection = RemoteConnection(
            name: name,
            hostname: hostname,
            port: portNumber,
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