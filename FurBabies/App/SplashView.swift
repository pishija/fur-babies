import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.Colors.primary)
                Text("FurBabies")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(Theme.Colors.textPrimary)
            }
        }
    }
}

#Preview {
    SplashView()
}
