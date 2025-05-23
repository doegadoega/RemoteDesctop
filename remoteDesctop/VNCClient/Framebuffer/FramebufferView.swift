import SwiftUI
import RoyalVNCKit

struct FramebufferView: View {
    @StateObject private var viewModel: FramebufferViewModel
    let onDisconnect: () -> Void
    
    @State private var scaleRatio: CGFloat = 1.0
    @State private var contentRect: CGRect = .zero
    @State private var isDragging: Bool = false
    @State private var lastMousePosition: CGPoint = .zero
    @State private var baseScaleRatio: CGFloat = 1.0
    @State private var currentScale: CGFloat = 1.0
    
    init(framebuffer: VNCFramebuffer?, settings: VNCConnection.Settings?, connection: VNCConnection?, onDisconnect: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: FramebufferViewModel(connection: connection, settings: settings))
        self.onDisconnect = onDisconnect
        viewModel.framebuffer = framebuffer
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let framebuffer = viewModel.framebuffer,
                   let cgImage = framebuffer.cgImage {
                    Image(uiImage: UIImage(cgImage: cgImage))
                        .resizable()
                        .aspectRatio(contentMode: viewModel.settings?.isScalingEnabled ?? true ? .fit : .fill)
                        .frame(width: contentRect.width, height: contentRect.height)
                        .position(x: contentRect.midX, y: contentRect.midY)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleMouseDrag(value)
                                }
                                .onEnded { value in
                                    handleMouseDragEnd(value)
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    handlePinch(value)
                                }
                                .onEnded { _ in
                                    baseScaleRatio = currentScale
                                }
                        )
                }
                
                VStack {
                    HStack {
                        Button(action: onDisconnect) {
                            Image(systemName: "eject.circle")
                                .font(.title)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                updateLayout(for: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                updateLayout(for: newSize)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
        .overlay(
            FramebufferView.KeyboardHandler(
                onKeyDown: viewModel.handleKeyDown,
                onKeyUp: viewModel.handleKeyUp
            )
        )
    }
    
    private func updateLayout(for size: CGSize) {
        guard let framebuffer = viewModel.framebuffer else { return }
        
        let containerBounds = size
        let fbSize = framebuffer.size.cgSize
        
        guard containerBounds.width > 0,
              containerBounds.height > 0,
              fbSize.width > 0,
              fbSize.height > 0 else {
            return
        }
        
        let targetAspectRatio = containerBounds.width / containerBounds.height
        let fbAspectRatio = fbSize.width / fbSize.height
        
        let ratio: CGFloat
        
        if fbAspectRatio >= targetAspectRatio {
            ratio = containerBounds.width / fbSize.width
        } else {
            ratio = containerBounds.height / fbSize.height
        }
        
        // Only allow downscaling, no upscaling
        scaleRatio = ratio < 1 ? ratio : 1
        
        var rect = CGRect(x: 0, y: 0,
                         width: fbSize.width * scaleRatio,
                         height: fbSize.height * scaleRatio)
        
        if rect.size.width < containerBounds.width {
            rect.origin.x = (containerBounds.width - rect.size.width) / 2.0
        }
        
        if rect.size.height < containerBounds.height {
            rect.origin.y = (containerBounds.height - rect.size.height) / 2.0
        }
        
        contentRect = rect
    }
    
    private func handleMouseDrag(_ value: DragGesture.Value) {
        let location = value.location
        let translatedLocation = translateToFramebufferCoordinates(location)
        
        if !isDragging {
            isDragging = true
            lastMousePosition = translatedLocation
            viewModel.handleMouseDown(at: translatedLocation)
        } else {
            viewModel.handleMouseMove(to: translatedLocation)
            lastMousePosition = translatedLocation
        }
    }
    
    private func handleMouseDragEnd(_ value: DragGesture.Value) {
        isDragging = false
        let location = value.location
        let translatedLocation = translateToFramebufferCoordinates(location)
        viewModel.handleMouseUp(at: translatedLocation)
    }
    
    private func handlePinch(_ value: CGFloat) {
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 2.0
        
        let newScale = baseScaleRatio * value
        
        currentScale = min(maxScale, max(minScale, newScale))
        
        scaleRatio = currentScale
        
        updateLayout(for: viewModel.framebuffer?.size.cgSize ?? .zero)
    }
    
    private func translateToFramebufferCoordinates(_ point: CGPoint) -> CGPoint {
        let x = (point.x - contentRect.origin.x) / scaleRatio
        let y = (point.y - contentRect.origin.y) / scaleRatio
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Keyboard Handling
extension FramebufferView {
    struct KeyboardHandler: UIViewRepresentable {
        let onKeyDown: (VNCKeyCode) -> Void
        let onKeyUp: (VNCKeyCode) -> Void
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.becomeFirstResponder()
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(onKeyDown: onKeyDown, onKeyUp: onKeyUp)
        }
        
        class Coordinator: NSObject {
            let onKeyDown: (VNCKeyCode) -> Void
            let onKeyUp: (VNCKeyCode) -> Void
            
            init(onKeyDown: @escaping (VNCKeyCode) -> Void, onKeyUp: @escaping (VNCKeyCode) -> Void) {
                self.onKeyDown = onKeyDown
                self.onKeyUp = onKeyUp
            }
            
            @objc func handleKeyDown(_ notification: Notification) {
                guard let keyCode = notification.userInfo?["keyCode"] as? VNCKeyCode else { return }
                onKeyDown(keyCode)
            }
            
            @objc func handleKeyUp(_ notification: Notification) {
                guard let keyCode = notification.userInfo?["keyCode"] as? VNCKeyCode else { return }
                onKeyUp(keyCode)
            }
        }
    }
} 