import SwiftUI
import AppKit

struct OverlayView: View {
    private enum KeyCode {
        static let space: UInt16 = 49
        static let escape: UInt16 = 53
        static let upArrow: UInt16 = 126
        static let downArrow: UInt16 = 125
        static let commandPlus: UInt16 = 24
        static let commandMinus: UInt16 = 27
        static let one: UInt16 = 18
        static let two: UInt16 = 19
        static let three: UInt16 = 20
        static let four: UInt16 = 21
    }

    @EnvironmentObject var model: TeleprompterModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(model.overlayOpacity))

            ScrollingScriptView()
                .environmentObject(model)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

            if !model.hideControlsInOverlay {
                OverlayMiniControls()
                    .environmentObject(model)
                    .padding(8)
            }
        }
        .frame(width: model.overlayWidth, height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard handleKeyDown(event) else { return event }
                return nil
            }
        }
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case KeyCode.space:
            model.toggleRunPause()
            return true
        case KeyCode.upArrow:
            model.increaseSpeed(step: event.modifierFlags.contains(.shift) ? 10 : 1.5)
            return true
        case KeyCode.downArrow:
            model.decreaseSpeed(step: event.modifierFlags.contains(.shift) ? 10 : 1.5)
            return true
        case KeyCode.escape:
            model.closeOverlay()
            return true
        case KeyCode.commandPlus where event.modifierFlags.contains(.command):
            model.increaseFont()
            return true
        case KeyCode.commandMinus where event.modifierFlags.contains(.command):
            model.decreaseFont()
            return true
        case KeyCode.one:
            model.setSpeedPreset(20)
            return true
        case KeyCode.two:
            model.setSpeedPreset(28)
            return true
        case KeyCode.three:
            model.setSpeedPreset(36)
            return true
        case KeyCode.four:
            model.setSpeedPreset(48)
            return true
        default:
            return false
        }
    }
}

struct ScrollingScriptView: View {
    @EnvironmentObject var model: TeleprompterModel

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                Text(model.scriptText.isEmpty ? "Paste your script in the main window and start." : model.scriptText)
                    .font(.system(size: model.fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .scaleEffect(x: model.mirrored ? -1 : 1, y: 1)
                    .offset(y: geo.size.height - model.offset)

                Spacer(minLength: geo.size.height * 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
        }
    }
}

struct OverlayMiniControls: View {
    @EnvironmentObject var model: TeleprompterModel

    var body: some View {
        HStack(spacing: 8) {
            Button(model.isRunning ? "Pause" : "Start") {
                model.toggleRunPause()
            }
            Button("Reset") {
                model.resetScroll()
            }
        }
        .buttonStyle(.borderless)
        .font(.system(size: 12, weight: .semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .foregroundStyle(.white)
    }
}
