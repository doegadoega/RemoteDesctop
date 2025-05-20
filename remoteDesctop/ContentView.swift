//
//  ContentView.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RemoteConnection.name) private var connections: [RemoteConnection]
    
    @State private var showingAddConnection = false
    @State private var searchText = ""
    
    var filteredConnections: [RemoteConnection] {
        if searchText.isEmpty {
            return connections
        } else {
            return connections.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.hostname.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredConnections) { connection in
                    NavigationLink(destination: ConnectionDetailView(connection: connection)) {
                        VStack(alignment: .leading) {
                            Text(connection.name)
                                .font(.headline)
                            HStack {
                                Text(connection.hostname)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                connectionTypeIcon(for: connection.connectionType)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteConnections)
            }
            .navigationTitle("Remote Desktop")
            .searchable(text: $searchText, prompt: "Search connections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddConnection = true }) {
                        Label("Add Connection", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddConnection) {
                AddConnectionView()
            }
            .overlay {
                if connections.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Connections", systemImage: "network.slash")
                        },
                        description: {
                            Text("Add a connection to get started")
                        },
                        actions: {
                            Button("Add Connection") {
                                showingAddConnection = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    )
                }
            }
        }
    }
    
    private func connectionTypeIcon(for type: ConnectionType) -> some View {
        switch type {
        case .rdp:
            return Image(systemName: "display")
                .foregroundColor(.blue)
        case .vnc:
            return Image(systemName: "desktopcomputer")
                .foregroundColor(.green)
        case .ssh:
            return Image(systemName: "terminal")
                .foregroundColor(.purple)
        }
    }

    private func deleteConnections(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredConnections[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: RemoteConnection.self, inMemory: true)
}
