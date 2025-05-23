import SwiftUI
import RoyalVNCKit

class FramebufferViewModel: ObservableObject {
    @Published var framebuffer: VNCFramebuffer?
    @Published var settings: VNCConnection.Settings?
    
    private var connection: VNCConnection?
    
    init(connection: VNCConnection?, settings: VNCConnection.Settings?) {
        self.connection = connection
        self.settings = settings
    }
    
    func handleMouseDown(at position: CGPoint) {
        connection?.mouseButtonDown(.left, x: UInt16(position.x), y: UInt16(position.y))
    }
    
    func handleMouseUp(at position: CGPoint) {
        connection?.mouseButtonUp(.left, x: UInt16(position.x), y: UInt16(position.y))
    }
    
    func handleMouseMove(to position: CGPoint) {
        connection?.mouseMove(x: UInt16(position.x), y: UInt16(position.y))
    }
    
    func handleKeyDown(_ key: VNCKeyCode) {
        connection?.keyDown(key)
    }
    
    func handleKeyUp(_ key: VNCKeyCode) {
        connection?.keyUp(key)
    }
    
    func handleScroll(delta: CGPoint, at position: CGPoint) {
//        connection?. sendScroll(delta: delta, at: position)
    }
} 
