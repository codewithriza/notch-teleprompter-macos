import SwiftUI
import AppKit

final class TeleprompterModel: ObservableObject {
    private enum Defaults {
        static let script = """
        [FOUNDER]
        Hi, I am building something new and I want to stay close to the camera while reading.
        [COFOUNDER]
        The overlay sits near the MacBook notch, scrolls at a steady pace, and stays out of the way while recording.
        [FOUNDER]
        Paste your own script here, tune the speed, and start recording.
        """

        static let speed = 28.0
        static let fontSize = 36.0
        static let opacity = 0.5
        static let width = 620.0
        static let notchOffset = 8.0
        static let otherSpeakerMultiplier = 1.45
    }

    @Published var scriptText: String = Defaults.script
    @Published var isRunning = false
    @Published var speed: Double = Defaults.speed
    @Published var fontSize: Double = Defaults.fontSize
    @Published var overlayOpacity: Double = Defaults.opacity
    @Published var mirrored = false
    @Published var hideControlsInOverlay = false
    @Published var overlayWidth: Double = Defaults.width
    @Published var notchOffset: Double = Defaults.notchOffset
    @Published var autoSpeakerSpeed = true
    @Published var otherSpeakerMultiplier: Double = Defaults.otherSpeakerMultiplier
    @Published var offset: CGFloat = 0

    private var displayLink: CVDisplayLink?
    private var lastTick: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

    private var panelController: OverlayPanelController?

    init() {
        setupDisplayLink()
    }

    deinit {
        if let link = displayLink {
            CVDisplayLinkStop(link)
        }
    }

    func showOverlay() {
        if panelController == nil {
            panelController = OverlayPanelController(model: self)
        }
        panelController?.show()
    }

    func closeOverlay() {
        isRunning = false
        panelController?.close()
        panelController = nil
    }

    func toggleRunPause() {
        isRunning.toggle()
        lastTick = CFAbsoluteTimeGetCurrent()
    }

    func resetScroll() {
        isRunning = false
        offset = 0
    }

    func increaseSpeed(step: Double = 5) {
        speed = min(500, speed + step)
    }

    func decreaseSpeed(step: Double = 5) {
        speed = max(5, speed - step)
    }

    func increaseFont() {
        fontSize = min(100, fontSize + 2)
    }

    func decreaseFont() {
        fontSize = max(14, fontSize - 2)
    }

    func setSpeedPreset(_ value: Double) {
        speed = min(500, max(5, value))
    }

    private func setupDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link else { return }
        displayLink = link

        CVDisplayLinkSetOutputCallback(link, { _, _, _, _, _, context in
            guard let context else { return kCVReturnSuccess }
            let model = Unmanaged<TeleprompterModel>.fromOpaque(context).takeUnretainedValue()
            model.tick()
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        CVDisplayLinkStart(link)
    }

    private func tick() {
        let now = CFAbsoluteTimeGetCurrent()
        let delta = now - lastTick
        lastTick = now
        guard isRunning else { return }
        let step = CGFloat(effectiveSpeed() * delta)
        DispatchQueue.main.async {
            self.offset += step
        }
    }

    private func effectiveSpeed() -> Double {
        guard autoSpeakerSpeed else { return speed }

        let speaker = currentSpeakerTag()
        if speaker == "[FOUNDER]" || speaker.isEmpty {
            return speed
        }
        return speed * otherSpeakerMultiplier
    }

    private func currentSpeakerTag() -> String {
        let lines = scriptText.components(separatedBy: .newlines)
        let lineHeight = max(20.0, fontSize + 8.0)
        if lines.isEmpty { return "" }

        let visibleLine = max(0, Int(offset / lineHeight))
        let clamped = min(lines.count - 1, visibleLine)
        var cursor = clamped

        while cursor >= 0 {
            let line = lines[cursor].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if line.hasPrefix("[") && line.hasSuffix("]") {
                return line
            }
            cursor -= 1
        }
        return ""
    }
}
