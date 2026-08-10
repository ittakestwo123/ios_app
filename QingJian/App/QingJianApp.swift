import SwiftData
import SwiftUI

@main
struct QingJianApp: App {
    private let container: ModelContainer
    @StateObject private var settings: AppSettings
    @StateObject private var timerEngine: FocusTimerEngine

    init() {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTestingResetState")
        if isUITesting, let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }

        _settings = StateObject(wrappedValue: AppSettings())
        _timerEngine = StateObject(wrappedValue: FocusTimerEngine())

        do {
            container = try PersistenceController.makeContainer(inMemory: isUITesting)
        } catch {
            fatalError("无法创建本地学习记录：\(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(timerEngine)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
        .modelContainer(container)
    }
}
