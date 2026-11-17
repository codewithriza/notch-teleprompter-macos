import SwiftUI

@main
struct NotchTeleprompterApp: App {
    @StateObject private var model = TeleprompterModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(model)
                .frame(minWidth: 540, minHeight: 500)
        }
        .windowResizability(.contentSize)
    }
}
