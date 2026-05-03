import SwiftUI

struct CreateDogFlowView: View {
    let userId: String
    var onComplete: ((String) -> Void)?

    @StateObject private var viewModel: CreateDogViewModel

    init(userId: String, onComplete: ((String) -> Void)? = nil) {
        self.userId = userId
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: CreateDogViewModel(userId: userId))
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            progressBar
            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomBar
        }
        .background(Theme.Colors.background)
        .fbToast($viewModel.errorMessage)
    }

    // MARK: - Sub-views

    private var navBar: some View {
        HStack {
            if viewModel.currentStep > 1 {
                Button {
                    withAnimation(.spring(duration: 0.3)) { viewModel.goBack() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            Text("Step \(viewModel.currentStep) of 5")
                .font(Theme.Typography.subheading)
                .foregroundStyle(Theme.Colors.textSecondary)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.top, Theme.Spacing.xs)
    }

    private var progressBar: some View {
        FBProgressSteps(totalSteps: 5, currentStep: viewModel.currentStep)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 1:
            DogNameStepView(viewModel: viewModel)
        case 2:
            DogBreedStepView(viewModel: viewModel)
        case 3:
            DogDetailsStepView(viewModel: viewModel)
        case 4:
            DogPersonalityStepView(viewModel: viewModel)
        default:
            DogExtrasStepView(viewModel: viewModel)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if viewModel.currentStep == 5 {
                FBButton(
                    title: "Create Profile",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        if let dogId = await viewModel.createDog() {
                            onComplete?(dogId)
                        }
                    }
                }
            } else {
                FBButton(
                    title: "Next",
                    isEnabled: viewModel.canAdvance
                ) {
                    withAnimation(.spring(duration: 0.3)) { viewModel.advance() }
                }
            }

            if viewModel.currentStep == 4 {
                Button("Skip for now") {
                    withAnimation(.spring(duration: 0.3)) { viewModel.advance() }
                }
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.xl)
    }
}

#Preview {
    CreateDogFlowView(userId: "preview-user")
}
