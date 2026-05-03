import SwiftUI

struct FBTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(label)
                .font(Theme.Typography.footnote)
                .foregroundStyle(labelColor)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
                .focused($isFocused)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.md)
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
    @Previewable @State var name = ""
    @Previewable @State var email = "bad-email"

    VStack(spacing: Theme.Spacing.lg) {
        FBTextField(label: "Name", placeholder: "Your dog's name", text: $name)
        FBTextField(
            label: "Email",
            placeholder: "you@example.com",
            text: $email,
            errorMessage: "Enter a valid email address",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
