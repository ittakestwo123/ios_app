import SwiftData
import SwiftUI

@main
struct QingJianApp: App {
    private let container: ModelContainer
    @StateObject private var settings = AppSettings()
    @StateObject private var timerEngine = FocusTimerEngine()

    init() {
        do {
            container = try PersistenceController.makeContainer()
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
