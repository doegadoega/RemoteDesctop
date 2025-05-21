//
//  SSHConnectionDelegate.swift
//  remoteDesctop
//
//  Created by Hiroshi Egami on 2025/05/22.
//

import Foundation

protocol SSHConnectionDelegate: AnyObject {
    func sshClientDidConnect(_ client: SSHClient)
    func sshClientDidDisconnect(_ client: SSHClient)
    func sshClient(_ client: SSHClient, didFailWithError error: Error)
    func sshClient(_ client: SSHClient, didReceiveOutput output: String)
}
