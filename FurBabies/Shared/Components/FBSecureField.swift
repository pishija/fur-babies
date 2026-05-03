import SwiftUI

struct FBSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(label)
                .font(Theme.Typography.footnote)
                .foregroundStyle(labelColor)

            HStack(spacing: 0) {
                Group {
                    if isRevealed {
                        TextField(placeholder, text: $text)
                            .submitLabel(submitLabel)
                            .onSubmit { onSubmit?() }
                    } else {
                        SecureField(placeholder, text: $text)
                            .submitLabel(submitLabel)
                            .onSubmit { onSubmit?() }
                    }
                }
                .focused($isFocused)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.leading, Theme.Spacing.md)

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .frame(width: 44, height: 44)
                }
            }
            .frame(height: 52)
            .background(Theme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .strokeBorder(borderColor, lineWidth: isFocused ? 1.5 : 1)
            }
            .animation(.easeInOut(duration: 0.15), value: isFocused)

            if let error = errorMessage {
                Text(error)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.error)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return Theme.Colors.error }
        if isFocused { return Theme.Colors.primary }
        return Theme.Colors.border
    }

    private var labelColor: Color {
        if errorMessage != nil { return Theme.Colors.error }
        if isFocused { return Theme.Colors.primary }
        return Theme.Colors.textSecondary
    }
}

#Preview {
    @Previewable @State var password = ""

    VStack(spacing: Theme.Spacing.lg) {
        FBSecureField(label: "Password", placeholder: "At least 8 characters", text: $password)
        FBSecureField(
            label: "Password",
            placeholder: "At least 8 characters",
            text: .constant("short"),
            errorMessage: "Password must be at least 8 characters"
        )
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
