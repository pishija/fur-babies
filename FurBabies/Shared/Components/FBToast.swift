import SwiftUI

enum FBToastStyle {
    case error, success, info, warning

    var icon: String {
        switch self {
        case .error:   return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .info:    return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .error:   return Theme.Colors.error
        case .success: return Theme.Colors.success
        case .info:    return Theme.Colors.info
        case .warning: return Theme.Colors.warning
        }
    }
}

private struct FBToastView: View {
    let message: String
    let style: FBToastStyle

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: style.icon)
                .foregroundStyle(style.color)
                .font(.system(size: 18))

            Text(message)
                .font(Theme.Typography.subheading)
                .foregroundStyle(Theme.Colors.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.bottom, Theme.Spacing.md)
    }
}

private struct FBToastModifier: ViewModifier {
    @Binding var message: String?
    var style: FBToastStyle = .error

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let msg = message {
                    FBToastView(message: msg, style: style)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task(id: msg) {
                            try? await Task.sleep(for: .seconds(3))
                            withAnimation(.spring(duration: 0.3)) { message = nil }
                        }
                }
            }
            .animation(.spring(duration: 0.3), value: message)
    }
}

extension View {
    func fbToast(_ message: Binding<String?>, style: FBToastStyle = .error) -> some View {
        modifier(FBToastModifier(message: message, style: style))
    }
}

#Preview {
    @Previewable @State var message: String? = "Something went wrong. Please try again."
    @Previewable @State var success: String? = "Profile saved successfully!"

    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        VStack(spacing: Theme.Spacing.md) {
            FBButton(title: "Show Error") { message = "Something went wrong. Please try again." }
            FBButton(title: "Show Success", style: .secondary) { success = "Profile saved!" }
        }
        .padding(Theme.Spacing.lg)
    }
    .fbToast($message, style: .error)
    .fbToast($success, style: .success)
}
