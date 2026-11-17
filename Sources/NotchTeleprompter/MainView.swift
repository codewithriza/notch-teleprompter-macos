import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: TeleprompterModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Notch Teleprompter")
                .font(.title3.weight(.semibold))

            TextEditor(text: $model.scriptText)
                .font(.system(size: 15))
                .frame(height: 230)
                .padding(8)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 12) {
                Button("Start Teleprompter") { model.showOverlay() }
                Button(model.isRunning ? "Pause" : "Start Scroll") { model.toggleRunPause() }
                Button("Reset") { model.resetScroll() }
                Button("Close Overlay") { model.closeOverlay() }
            }

            Group {
                sliderRow(title: "Speed", value: $model.speed, range: 5...500, format: "%.0f px/s")
                sliderRow(title: "Font", value: $model.fontSize, range: 14...100, format: "%.0f")
                sliderRow(title: "Opacity", value: $model.overlayOpacity, range: 0.1...0.9, format: "%.2f")
                sliderRow(title: "Overlay Width", value: $model.overlayWidth, range: 500...700, format: "%.0f px")
                sliderRow(title: "Notch Offset", value: $model.notchOffset, range: 0...60, format: "%.0f px")
                sliderRow(title: "Others Mult", value: $model.otherSpeakerMultiplier, range: 1.0...2.2, format: "%.2fx")
            }

            HStack(spacing: 18) {
                Toggle("Mirror Text", isOn: $model.mirrored)
                Toggle("Hide Overlay Controls", isOn: $model.hideControlsInOverlay)
                Toggle("Auto Speaker Speed", isOn: $model.autoSpeakerSpeed)
            }

            Text("Hotkeys in overlay: Space pause/resume, ↑/↓ speed, Cmd +/- font, Esc close.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                model.showOverlay()
            }
        }
    }

    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        HStack {
            Text(title).frame(width: 90, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: format, value.wrappedValue))
                .monospacedDigit()
                .frame(width: 90, alignment: .trailing)
        }
    }
}
