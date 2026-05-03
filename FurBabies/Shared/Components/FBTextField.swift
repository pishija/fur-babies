import SwiftUI

struct FBTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(Theme.Typography.footnote)
                .fontWeight(.medium)
                .foregroundStyle(labelColor)

            HStack(spacing: Theme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .frame(width: 20, height: 20)
                }

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
                    .focused($isFocused)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
            }
            .frame(height: 48)
            .padding(.horizontal, 14)
            .background(Theme.Colors.muted)
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
        return Theme.Colors.textSecondary
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var email = ""

    VStack(spacing: Theme.Spacing.lg) {
        FBTextField(label: "First Name", placeholder: "Enter your first name", text: $name)
        FBTextField(
            label: "Email",
            placeholder: "you@example.com",
            text: $email,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
        FBTextField(
            label: "Email",
            placeholder: "you@example.com",
            text: .constant("bad"),
            errorMessage: "Enter a valid email address",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
