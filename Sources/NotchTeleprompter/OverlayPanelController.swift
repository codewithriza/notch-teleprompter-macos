import SwiftUI
import AppKit

final class OverlayPanelController {
    private let panel: NSPanel
    private weak var model: TeleprompterModel?

    init(model: TeleprompterModel) {
        self.model = model
        let content = OverlayView().environmentObject(model)
        let host = NSHostingView(rootView: content)

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: model.overlayWidth, height: 220),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.contentView = host
    }

    func show() {
        positionNearNotch()
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel.orderOut(nil)
    }

    private func positionNearNotch() {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let panelSize = panel.frame.size
        let x = visible.midX - (panelSize.width / 2)
        let notchOffset = model?.notchOffset ?? 8
        let y = visible.maxY - panelSize.height - notchOffset
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
