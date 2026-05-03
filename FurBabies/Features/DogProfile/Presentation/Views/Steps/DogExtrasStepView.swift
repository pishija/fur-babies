import SwiftUI

struct DogExtrasStepView: View {
    @ObservedObject var viewModel: CreateDogViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                sizeClassSection
                optionalFieldsCard
                visibilityToggle
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("A few more details")
                .font(Theme.Typography.title1)
                .foregroundStyle(Theme.Colors.textPrimary)
            Text("These are optional but help personalise your dog's experience.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }

    private var sizeClassSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Size class")
                .font(Theme.Typography.footnote)
                .fontWeight(.medium)
                .foregroundStyle(Theme.Colors.textSecondary)

            HStack(spacing: Theme.Spacing.xs) {
                ForEach(DogSizeClass.allCases, id: \.self) { size in
                    sizeButton(size)
                }
            }
        }
    }

    private func sizeButton(_ size: DogSizeClass) -> some View {
        let isSelected = viewModel.sizeClass == size
        return Button {
            viewModel.sizeClass = size
        } label: {
            Text(size.displayName)
                .font(Theme.Typography.subheading)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .strokeBorder(
                            isSelected ? Theme.Colors.primary : Theme.Colors.border,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var optionalFieldsCard: some View {
        FBCard {
            VStack(spacing: 0) {
                fieldRow(label: "Coat colour", text: $viewModel.coatColour, placeholder: "e.g. Golden")
                FBDivider()
                fieldRow(label: "Microchip no.", text: $viewModel.microchip, placeholder: "e.g. 985112345678901", keyboard: .numberPad)
                FBDivider()
                neuteredToggleRow
            }
        }
    }

    private func fieldRow(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.primary)
                .frame(maxWidth: 180)
        }
        .frame(height: 52)
    }

    private var neuteredToggleRow: some View {
        HStack {
            Text(viewModel.sex?.neuteredLabel ?? "Neutered")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
            Spacer()
            Toggle("", isOn: $viewModel.isNeutered)
                .labelsHidden()
                .tint(Theme.Colors.primary)
        }
        .frame(height: 52)
    }

    private var visibilityToggle: some View {
        FBCard {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Public profile")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Visible for matching and on the walk map")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                Spacer()
                Toggle("", isOn: $viewModel.isPublic)
                    .labelsHidden()
                    .tint(Theme.Colors.primary)
            }
        }
    }
}

#Preview {
    CreateDogFlowView(userId: "preview")
}
