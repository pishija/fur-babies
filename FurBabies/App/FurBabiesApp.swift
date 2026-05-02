import SwiftUI

@main
struct FurBabiesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
