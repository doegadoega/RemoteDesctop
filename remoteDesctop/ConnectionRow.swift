import SwiftUI

struct ConnectionRow: View {
    let connection: RemoteConnection
    
    var body: some View {
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
} 