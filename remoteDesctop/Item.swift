//
//  Item.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/20.
//

import Foundation
import SwiftData

@Model
final class RemoteConnection {
    var name: String
    var hostname: String
    var port: Int
    var username: String
    var password: String
    var connectionType: ConnectionType
    var lastConnected: Date?
    var createdAt: Date
    
    init(name: String, hostname: String, port: Int, username: String, password: String, connectionType: ConnectionType, lastConnected: Date? = nil) {
        self.name = name
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.connectionType = connectionType
        self.lastConnected = lastConnected
        self.createdAt = Date()
    }
}

enum ConnectionType: String, Codable {
    case rdp = "Remote Desktop"
    case vnc = "VNC"
    case ssh = "SSH"
}
