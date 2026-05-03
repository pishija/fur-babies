import SwiftUI

struct FBProgressSteps: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                capsule(for: step)
                if step < totalSteps {
                    Spacer(minLength: Theme.Spacing.xs)
                }
            }
        }
        .animation(.spring(duration: 0.3), value: currentStep)
    }

    private func capsule(for step: Int) -> some View {
        Capsule()
            .fill(color(for: step))
            .frame(height: 4)
            .frame(maxWidth: step == currentStep ? .infinity : nil)
            .frame(minWidth: step < currentStep ? 0 : nil)
    }

    private func color(for step: Int) -> Color {
        if step < currentStep { return Theme.Colors.primary.opacity(0.35) }
        if step == currentStep { return Theme.Colors.primary }
        return Theme.Colors.border
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xl) {
        FBProgressSteps(totalSteps: 5, currentStep: 1)
        FBProgressSteps(totalSteps: 5, currentStep: 3)
        FBProgressSteps(totalSteps: 5, currentStep: 5)
    }
    .padding(Theme.Spacing.lg)
    .background(Theme.Colors.background)
}
