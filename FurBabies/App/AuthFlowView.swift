import SwiftUI

// Stub — replaced by Features/Auth implementation
struct AuthFlowView: View {
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            Text("Auth")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    AuthFlowView()
}
