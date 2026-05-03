import SwiftUI

struct DogDetailsStepView: View {
    @ObservedObject var viewModel: CreateDogViewModel
    @State private var showingBirthdayPicker = false
    @FocusState private var weightFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                sexButtons
                detailsSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Header

    private var header: some View {
        Text("Tell us about \(viewModel.name.isEmpty ? "your dog" : viewModel.name)")
            .font(Theme.Typography.title1)
            .foregroundStyle(Theme.Colors.textPrimary)
    }

    // MARK: - Sex buttons

    private var sexButtons: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: 12) {
                sexButton(.male)
                sexButton(.female)
            }

            if let error = viewModel.sexError {
                Text(error)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.error)
            }
        }
    }

    private func sexButton(_ sex: DogSex) -> some View {
        let isSelected = viewModel.sex == sex
        return Button {
            viewModel.sex = sex
            viewModel.sexError = nil
        } label: {
            HStack(spacing: 8) {
                Text(sex == .male ? "♂" : "♀")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(isSelected ? Theme.Colors.textOnBrand : Theme.Colors.textSecondary)
                Text(sex.displayName)
                    .font(Theme.Typography.body)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundStyle(isSelected ? Theme.Colors.textOnBrand : Theme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: Theme.Radius.lg)
                        .strokeBorder(Theme.Colors.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Details card

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            detailsCard

            if let error = viewModel.birthdayError {
                Text(error)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.error)
            }

            if let error = viewModel.weightError {
                Text(error)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.error)
            }
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            birthdayRow

            if showingBirthdayPicker {
                birthdayPickerExpansion
            }

            Divider().background(Theme.Colors.border)
            weightRow
        }
        .background(Theme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .strokeBorder(Theme.Colors.border, lineWidth: 1)
        }
    }

    private var birthdayRow: some View {
        Button {
            weightFocused = false
            withAnimation(.spring(duration: 0.3)) {
                showingBirthdayPicker.toggle()
            }
        } label: {
            HStack {
                Text("Birthday")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Text(viewModel.birthday.formatted(date: .abbreviated, time: .omitted))
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .frame(height: 52)
            .padding(.horizontal, Theme.Spacing.md)
            .background(showingBirthdayPicker ? Theme.Colors.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var weightRow: some View {
        HStack {
            Text("Weight")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                TextField("0", text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.primary)
                    .focused($weightFocused)
                    .frame(maxWidth: 80)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { weightFocused = false }
                                .font(Theme.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.primary)
                        }
                    }
                    .onChange(of: weightFocused) { _, focused in
                        if focused {
                            withAnimation(.spring(duration: 0.3)) {
                                showingBirthdayPicker = false
                            }
                        }
                    }
                if !viewModel.weightText.isEmpty {
                    Text("kg")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.primary)
                }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, Theme.Spacing.md)
        .background(weightFocused ? Theme.Colors.primary.opacity(0.06) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(duration: 0.3)) {
                showingBirthdayPicker = false
            }
            weightFocused = true
        }
    }

    private var birthdayPickerExpansion: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Done") {
                    withAnimation(.spring(duration: 0.3)) {
                        showingBirthdayPicker = false
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Colors.primary)
            }
            .frame(height: 44)
            .padding(.horizontal, Theme.Spacing.md)

            DatePicker(
                "",
                selection: $viewModel.birthday,
                in: Calendar.current.date(byAdding: .year, value: -30, to: .now)!...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(.bottom, Theme.Spacing.xs)
        }
    }
}

#Preview {
    CreateDogFlowView(userId: "preview")
}
